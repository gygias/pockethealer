//
//  RaidFrameView.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "RaidFrameView.h"

#import "Player.h"

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
#define RAID_FRAME_NAME_INSET_X 5

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
    
    //NSLog(@"%@: drawRect: %f %f %f %f",[self class],rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    double snapshottedHealthPercentage = self.player.currentHealth.doubleValue / self.player.character.health.doubleValue;//(CGFloat)( arc4random() % 100 ) / 100 ;
    //if ( snapshottedHealthPercentage < 1.0 )
    //    NSLog(@"%@ is at %0.2f%",self.player,snapshottedHealthPercentage * 100);
    [self _drawBackgroundInRect:rect];
    [self _drawBorderInRect:rect];
    [self _drawHealthInRect:rect withHealth:snapshottedHealthPercentage];
    // do incoming heals overlap absorbs?
    [self _drawAbsorbsInRect:rect withHealth:snapshottedHealthPercentage];
    [self _drawIncomingHealsInRect:rect withHealth:snapshottedHealthPercentage];
    [self _drawTextInRect:rect];
    [self _drawResourceBarInRect:rect];
    [self _drawStatusEffectsInRect:rect];
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
    
    CGContextSetStrokeColorWithColor(context,
                                     self.selected ? [UIColor whiteColor].CGColor : [UIColor blueColor].CGColor);
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
    if ( self.player.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat width = ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    
    CGRect rectangle = CGRectMake( rect.origin.x + RAID_FRAME_HEALTH_INSET, rect.origin.y + RAID_FRAME_HEALTH_INSET, width, rect.size.height - ( RAID_FRAME_HEALTH_INSET * 2 ));
    CGContextAddRect(context, rectangle);
    
    //NSLog(@"%@ is the color %@",self.player,self.player.character.hdClass.classColor);
    CGContextSetStrokeColorWithColor(context,
                                     self.player.character.hdClass.classColor.CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   self.player.character.hdClass.classColor.CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawIncomingHealsInRect:(CGRect)rect withHealth:(double)health
{
    if ( self.player.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat originX = rect.origin.x + RAID_FRAME_HEALTH_INSET + ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    CGFloat incomingHeals = 0;//( (CGFloat)( arc4random() % 20 ) / 100 );
    //NSLog(@"incomingHeals: %f origin: %f",incomingHeals,originX);
    
    if ( incomingHeals == 0 )
        return;
    
    CGFloat incomingHealsDrawableWidth = ( incomingHeals + health > 1 ? 1 - health : incomingHeals ) * rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 );
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
    if ( self.player.isDead )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat originX = rect.origin.x + RAID_FRAME_HEALTH_INSET + ( health * rect.size.width ) - ( RAID_FRAME_HEALTH_INSET * 2 );
    CGFloat absorbs = self.player.currentAbsorb.doubleValue / self.player.character.health.doubleValue;//( (CGFloat)( arc4random() % 50 ) / 100 );
    //NSLog(@"absorbs: %f origin: %f",absorbs,originX);
    
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

- (void)_drawTextInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint namePoint = CGPointMake(rect.origin.x + RAID_FRAME_NAME_INSET_X, ( rect.size.height / 2 ) + rect.origin.y);
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if ( self.player.isDead )
        attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [self.player.character.name drawAtPoint:namePoint withAttributes:attributes];
}

- (void)_drawResourceBarInRect:(CGRect)rect
{
    double resourcePercentage = self.player.currentResources.doubleValue / self.player.character.power.doubleValue;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = rect.size.height / 6;
    CGFloat originY = ( rect.origin.y + RAID_FRAME_HEALTH_INSET ) + ( rect.size.height - height );
    CGFloat width = ( rect.size.width - ( RAID_FRAME_HEALTH_INSET * 2 ) ) * resourcePercentage;
    
    CGRect rectangle = CGRectMake( rect.origin.x + RAID_FRAME_HEALTH_INSET,
                                  originY,
                                  width,
                                  height);
    CGContextAddRect(context, rectangle);
    
    CGContextSetStrokeColorWithColor(context,
                                     self.player.character.hdClass.resourceColor.CGColor);
    
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context,
                                   self.player.character.hdClass.resourceColor.CGColor);
    CGContextFillRect(context, rectangle);
}

- (void)_drawStatusEffectsInRect:(CGRect)rect
{
    
}


@end
