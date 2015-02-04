//
//  RaidFrameView.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "RaidFrameView.h"

#import "Entity.h"
#import "HDClass.h"
#import "Effect.h"
#import "UIColor+Extensions.h"
#import "ImageFactory.h"
#import "Encounter.h"
#import "Logging.h"

@interface RaidFrameView ()
- (void)_drawBackgroundInRect:(CGRect)rect;
- (void)_drawBorderInRect:(CGRect)rect;
- (void)_drawHealthInRect:(CGRect)rect withHealth:(double)health;
- (void)_drawIncomingHealsInRect:(CGRect)rect withHealth:(double)health;
- (void)_drawAbsorbsInRect:(CGRect)rect withHealth:(double)health;
- (void)_drawTextInRect:(CGRect)rect;
- (void)_drawResourceBarInRect:(CGRect)rect;
- (void)_drawStatusEffectsInRect:(CGRect)rect;
@end

@implementation RaidFrameView

#define RAID_FRAME_BORDER_INSET 1
#define RAID_FRAME_HEALTH_INSET ( RAID_FRAME_BORDER_INSET + 1 )
#define RAID_FRAME_NAME_INSET_X ( ROLE_ICON_ORIGIN_X + ROLE_ICON_SIZE + 3 )

+ (CGSize)desiredSize
{
    return CGSizeMake(70, 40);
}

- (void)_setDefaults
{
}

- (void)awakeFromNib
{
    [self _setDefaults];
}

- (id)init {
    if ( self = [super init] )
    {
        [self _setDefaults];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] )
    {
        [self _setDefaults];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //PHLog(@"%@: drawRect: %f %f %f %f",[self class],rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    double snapshottedHealthPercentage = self.entity.currentHealth.doubleValue / self.entity.health.doubleValue;//(CGFloat)( arc4random() % 100 ) / 100 ;
    //if ( snapshottedHealthPercentage < 1.0 )
    //    PHLog(@"%@ is at %0.2f%",self.player,snapshottedHealthPercentage * 100);
    [self _drawBackgroundInRect:rect];
    [self _drawBorderInRect:rect];
    [self _drawHealthInRect:rect withHealth:snapshottedHealthPercentage];
    // do incoming heals overlap absorbs?
    [self _drawIncomingHealsInRect:rect withHealth:snapshottedHealthPercentage];
    [self _drawAbsorbsInRect:rect withHealth:snapshottedHealthPercentage];
    [self _drawRoleIconInRect:rect];
    [self _drawTextInRect:rect];
    [self _drawResourceBarInRect:rect];
    [self _drawSpellCastingInRect:rect];
    [self _drawStatusEffectsInRect:rect];
    [self _drawAuxResourcesInRect:rect];
}

- (void)_drawBackgroundInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw background
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor grayColor].CGColor);
    CGRect rectangle = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   [UIColor grayColor].CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawBorderInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw border
    /*CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);*/
    
    CGContextSetLineWidth(context, 0.5);
    
    /* could be
     CGRect rectangle = CGRectMake(60,170,200,80);
     CGContextAddRect(context, rectangle);
     */
    
    UIColor *borderColor = [self.encounter entityIsTargetedByEntity:self.entity] ? [UIColor redColor] :
                            ( self.selected ? [UIColor whiteColor] : [UIColor blueColor] );
    
    CGContextSetStrokeColorWithColor(context,borderColor.CGColor);
    CGContextMoveToPoint(context, rect.origin.x + RAID_FRAME_BORDER_INSET, rect.origin.y + RAID_FRAME_BORDER_INSET);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - RAID_FRAME_BORDER_INSET, rect.origin.y + RAID_FRAME_BORDER_INSET);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - RAID_FRAME_BORDER_INSET, rect.origin.y + rect.size.height - RAID_FRAME_BORDER_INSET);
    CGContextAddLineToPoint(context, rect.origin.x + RAID_FRAME_BORDER_INSET, rect.origin.y + rect.size.height - RAID_FRAME_BORDER_INSET);
    CGContextAddLineToPoint(context, rect.origin.x + RAID_FRAME_BORDER_INSET, rect.origin.y + RAID_FRAME_BORDER_INSET);
    CGContextStrokePath(context);
    //CGColorSpaceRelease(colorspace);
    //CGColorRelease(color);
}

- (void)_drawHealthInRect:(CGRect)rect withHealth:(double)health
{
    if ( self.entity.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat width = ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    
    CGRect rectangle = CGRectMake( rect.origin.x + RAID_FRAME_HEALTH_INSET, rect.origin.y + RAID_FRAME_HEALTH_INSET, width, rect.size.height - ( RAID_FRAME_HEALTH_INSET * 2 ));
    CGContextAddRect(context, rectangle);
    
    //PHLog(@"%@ is the color %@",self.player,self.player.character.hdClass.classColor);
    CGContextSetStrokeColorWithColor(context,
                                     self.entity.hdClass.classColor.CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   self.entity.hdClass.classColor.CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawIncomingHealsInRect:(CGRect)rect withHealth:(double)health
{
    if ( self.entity.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat originX = rect.origin.x + RAID_FRAME_HEALTH_INSET + ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    __block CGFloat incomingHeals = 0;
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        if ( player.castingSpell.target == self.entity && player.castingSpell.healing.doubleValue )
            incomingHeals += player.castingSpell.healing.doubleValue;
    }];
    
    if ( incomingHeals <= 0 )
        return;
    
    double incomingHealsPercentage = incomingHeals / self.entity.health.doubleValue * 1.5; // TODO why 1.5
    //NSLog(@"%@ incoming heals: %0.2f / %0.3f",self.entity,incomingHeals,incomingHealsPercentage);
    CGFloat incomingHealsDrawableWidth = ( incomingHealsPercentage + health > 1 ? 1 - health : incomingHealsPercentage ) * rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 );
    // maybe should have each particular method pass out an inner rect discounting their own offsets / "owned space"
    //if ( ( originX + width ) > rect.size.width - RAID_FRAME_BORDER_INSET * 2 - RAID_FRAME_HEALTH_INSET * 2 - )
    
    CGRect rectangle = CGRectMake( originX, rect.origin.y + RAID_FRAME_HEALTH_INSET, incomingHealsDrawableWidth, rect.size.height - ( RAID_FRAME_HEALTH_INSET * 2 ));
    CGContextAddRect(context, rectangle);
    
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor darkGrayColor].CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   [UIColor darkGrayColor].CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawAbsorbsInRect:(CGRect)rect withHealth:(double)health
{
    if ( self.entity.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat originX = rect.origin.x + RAID_FRAME_HEALTH_INSET + ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    CGFloat absorbs = self.entity.currentAbsorb.doubleValue / self.entity.health.doubleValue;//( (CGFloat)( arc4random() % 50 ) / 100 );
    //PHLog(@"absorbs: %f origin: %f",absorbs,originX);
    
    // optimize for <= incoming heals?
    if ( absorbs == 0 )
        return;
    
    CGFloat absorbsDrawableWidth = ( absorbs + health > 1 ? 1 - health : absorbs ) * rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 );
    // maybe should have each particular method pass out an inner rect discounting their own offsets / "owned space"
    //if ( ( originX + width ) > rect.size.width - RAID_FRAME_BORDER_INSET * 2 - RAID_FRAME_HEALTH_INSET * 2 - )
    
    CGRect absorbsRect = CGRectMake( originX, rect.origin.y + RAID_FRAME_HEALTH_INSET, absorbsDrawableWidth, rect.size.height - ( RAID_FRAME_HEALTH_INSET * 2 ));
    
    CGContextAddRect(context, absorbsRect);
    
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor lightGrayColor].CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   [UIColor lightGrayColor].CGColor);
    CGContextFillRect(context, absorbsRect);
    
    // draw the blue lines thing
    CGFloat originY = rect.origin.y + RAID_FRAME_HEALTH_INSET;
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor cyanColor].CGColor);
    while ( originY < rect.origin.y + rect.size.height - RAID_FRAME_HEALTH_INSET * 2 )
    {
        CGContextMoveToPoint(context, originX, originY);
        CGContextAddLineToPoint(context, originX + absorbsRect.size.width, originY + 5);
        CGContextStrokePath(context);
        originY += 3;
    }    
}

#define ROLE_ICON_ORIGIN_X 3
#define ROLE_ICON_ORIGIN_Y ROLE_ICON_ORIGIN_X
#define ROLE_ICON_SIZE 10
#define ROLE_ICON_ORIGIN_Y_OFFSET_FOR_NAME_DRAWING_TODO (-2)

- (void)_drawRoleIconInRect:(CGRect)rect
{
    UIImage *roleImage = [ImageFactory imageForRole:self.entity.hdClass.role];
    
    if ( ! roleImage && ! self.entity.isEnemy )
    {
        PHLog(@"TODO: stressed mac out of disk space renders this intermittently returning nil");
        [NSException raise:@"RoleImageIsNilException" format:@"role image should not be nil!"];
    }
    CGRect imageRect = CGRectMake(rect.origin.x + ROLE_ICON_ORIGIN_X, rect.origin.y + ROLE_ICON_ORIGIN_Y, ROLE_ICON_SIZE, ROLE_ICON_SIZE);
    [roleImage drawInRect:imageRect];
//    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:10] };
//    if ( self.entity.hdClass.isHealerClass )
//        [@"H" drawInRect:imageRect withAttributes:attributes];
//    else if ( self.entity.hdClass.isTank )
//        [@"T" drawInRect:imageRect withAttributes:attributes];
//    else if ( self.entity.hdClass.isDPS )
//        [@"D" drawInRect:imageRect withAttributes:attributes];
}

- (void)_drawTextInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint namePoint = CGPointMake(rect.origin.x + RAID_FRAME_NAME_INSET_X, rect.origin.y + ROLE_ICON_ORIGIN_Y + ROLE_ICON_ORIGIN_Y_OFFSET_FOR_NAME_DRAWING_TODO);
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 5;
    shadow.shadowOffset = CGSizeMake(1.5, 1.5);
    NSMutableDictionary *attributes =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [UIColor whiteColor], NSForegroundColorAttributeName,
            shadow, NSShadowAttributeName,
         nil];
    
    
    BOOL truncated = NO;
    NSString *textToDraw = self.entity.name;
    CGSize stringSize = [textToDraw sizeWithAttributes:attributes];
    stringSize.width += 20;
    while ( stringSize.width > rect.size.width && [textToDraw length] > 0 )
    {
        // TODO because these are instantiated for each draw, this is extra inefficient
        textToDraw = [textToDraw substringToIndex:[textToDraw length] - 2];
        stringSize = [textToDraw sizeWithAttributes:attributes];
        stringSize.width += 20;
        truncated = YES;
    }
    if ( truncated )
    {
        textToDraw = [textToDraw substringToIndex:[textToDraw length] - 2];
        textToDraw = [textToDraw stringByAppendingString:@"…"];
        
        // TODO all around here
        stringSize = [textToDraw sizeWithAttributes:attributes];
        while ( stringSize.width > rect.size.width && [textToDraw length] > 1 )
        {
            // TODO because these are instantiated for each draw, this is extra inefficient
            textToDraw = [textToDraw stringByReplacingCharactersInRange:NSMakeRange([textToDraw length] - 2, 1) withString:@""];
            stringSize = [textToDraw sizeWithAttributes:attributes];
            stringSize.width += 20;
            truncated = YES;
        }
    }
    
    [textToDraw drawAtPoint:namePoint withAttributes:attributes];
}

- (void)_drawResourceBarInRect:(CGRect)rect
{
    double resourcePercentage = self.entity.currentResources.doubleValue / self.entity.power.doubleValue;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = rect.size.height / 7;
    CGFloat originY = ( rect.origin.y + RAID_FRAME_HEALTH_INSET ) + ( rect.size.height - height - RAID_FRAME_BORDER_INSET - RAID_FRAME_HEALTH_INSET - 1 );
    CGFloat width = ( rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 ) ) * resourcePercentage;
    
    CGRect rectangle = CGRectMake( rect.origin.x + RAID_FRAME_HEALTH_INSET,
                                  originY,
                                  width,
                                  height);
    CGContextAddRect(context, rectangle);
    
    CGContextSetStrokeColorWithColor(context,
                                     self.entity.hdClass.resourceColor.CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   self.entity.hdClass.resourceColor.CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawSpellCastingInRect:(CGRect)rect
{
    Spell *castingSpell = self.entity.castingSpell;
    if ( ! castingSpell || castingSpell.castTime.doubleValue <= 0 )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = rect.size.height / 7;
    CGFloat originY = ( rect.origin.y + RAID_FRAME_HEALTH_INSET ) + ( rect.size.height - height - RAID_FRAME_BORDER_INSET - RAID_FRAME_HEALTH_INSET - 1 );
    CGFloat width = ( rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 ) );
    
    CGRect rectangle = CGRectMake( rect.origin.x + RAID_FRAME_HEALTH_INSET,
                                  originY,
                                  width,
                                  height);
    NSTimeInterval timeSinceCastStart = [[NSDate date] timeIntervalSinceDate:castingSpell.lastCastStartDate];
    double castPercentage = timeSinceCastStart / castingSpell.castTime.doubleValue;
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:5],
                                  NSForegroundColorAttributeName : [UIColor whiteColor] };
    [castingSpell.name drawInRect:rectangle withAttributes:attributes];
    CGRect castNub = CGRectMake(rectangle.origin.x + ( castPercentage * rectangle.size.width ),
                                rectangle.origin.y + rectangle.size.height - 3,
                                3,
                                3);
    CGContextAddRect(context, castNub);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
}

#define STATUS_EFFECT_ORIGIN_OFFSET_X [RaidFrameView desiredSize].width * .5
#define STATUS_EFFECT_ORIGIN_OFFSET_Y [RaidFrameView desiredSize].height * .6
#define STATUS_EFFECT_WIDTH 7
#define STATUS_EFFECT_HEIGHT STATUS_EFFECT_WIDTH

- (void)_drawStatusEffectsInRect:(CGRect)rect
{
    __block NSInteger maxVisibleStatusEffects = 5;
    [self.entity.statusEffects enumerateObjectsUsingBlock:^(Effect *effect, NSUInteger idx, BOOL *stop) {
        if ( effect.drawsInFrame || ( effect.source == self.player ) )
        {
            CGRect effectRect = CGRectMake(rect.origin.x + STATUS_EFFECT_ORIGIN_OFFSET_X + idx * STATUS_EFFECT_WIDTH,
                                           rect.origin.y + STATUS_EFFECT_ORIGIN_OFFSET_Y,
                                           STATUS_EFFECT_WIDTH,
                                           STATUS_EFFECT_HEIGHT);
            [effect.image drawInRect:effectRect blendMode:kCGBlendModeNormal alpha:1.0];
            
            if ( effect.duration )
            {
                double percentage = [[NSDate date] timeIntervalSinceDate:effect.startDate] / effect.duration;
                [self _drawCooldownClockInRect:effectRect withPercentage:percentage];
            }
            
            if ( --maxVisibleStatusEffects == 0 )
                *stop = YES;
        }
    }];
}

- (void)_drawCooldownClockInRect:(CGRect)rect withPercentage:(double)percentage
{
    //CGFloat offset = spellRect.size.height * ( 1 - cooldownPercentage );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double cooldownInDegress = percentage * 360.0;
    double theta = ( cooldownInDegress + 90 );
    if ( theta > 360 )
        theta -= 360;
    double thetaRadians = theta * ( M_PI / 180 );
    CGPoint unitPoint = CGPointMake(cos(thetaRadians), sin(thetaRadians));
    //PHLog(@"%0.2f'->%0.2f' (%0.2f) (%0.1f,%0.1f)",cooldownInDegress,theta,thetaRadians,unitPoint.x,unitPoint.y);
    
    CGContextSetFillColorWithColor(context,[UIColor cooldownClockColor].CGColor);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + ( rect.size.width / 2 ), rect.origin.y);
    CGPoint midPoint = CGPointMake(rect.origin.x + ( rect.size.width / 2 ), rect.origin.y + ( rect.size.height / 2 ));
    CGContextAddLineToPoint(context, midPoint.x, midPoint.y);
    
    CGPoint mysteryPoint = CGPointMake(midPoint.x + ( unitPoint.x * ( rect.size.width / 2 ) ), midPoint.y - ( unitPoint.y * ( rect.size.height / 2 )));
    CGContextAddLineToPoint(context, mysteryPoint.x, mysteryPoint.y); // the mystery point
    double rotatedByDegress = ( 360 - cooldownInDegress );
    if ( rotatedByDegress <= 90 )
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    if ( rotatedByDegress <= 180 )
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    if ( rotatedByDegress <= 270 )
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    //if ( theta >= 180 && theta <= 90 )
    //    CGContextAddLineToPoint(context, spellRect.origin.x, spellRect.origin.y);
    //CGRect rectangle = CGRectMake(spellRect.origin.x,spellRect.origin.y + offset,spellRect.size.width,spellRect.size.height - offset);
    //CGContextAddRect(context, rectangle);
    CGContextFillPath(context);
}

- (void)_drawAuxResourcesInRect:(CGRect)rect
{
    UIColor *auxColor = self.entity.hdClass.auxResourceColor;
    if ( ! auxColor )
        return;
    
    NSUInteger idx = 0;
    for ( ; idx < self.entity.currentAuxiliaryResources.unsignedIntegerValue; idx++ )
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //CGRect bounds = [self bounds];
        
        //CGPoint center;
        //center.x = bounds.origin.x + bounds.size.width / 2.0;
        //center.y = bounds.origin.y + bounds.size.height / 2.0;
        //CGContextSaveGState(ctx);
        
        CGContextSetLineWidth(ctx,5);
        CGContextSetFillColorWithColor(ctx, auxColor.CGColor);
        CGContextAddArc(ctx,rect.origin.x + 5 * idx + 5,rect.origin.y + rect.size.height / 2,2,0.0,M_PI*2,YES);
        CGContextFillPath(ctx);
    }
}

@end
