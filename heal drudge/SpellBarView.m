//
//  SpellBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "SpellBarView.h"

#import "Spell.h"
#import "Entity.h"
#import "UIColor+Extensions.h"

#define SPELL_HEIGHT 45
#define SPELL_WIDTH SPELL_HEIGHT
#define SPELLS_PER_ROW 5

@interface SpellBarView (PrivateProperties)
// It is not possible to add members and properties to an existing class via a category — only methods.
//@property NSMutableArray *spells;
@end

@implementation SpellBarView

@synthesize player = _player;

- (void)setPlayer:(Entity *)player
{
    // only reason this was overridden
    //self.spells = [[Spell castableSpellsForCharacter:player] mutableCopy];
    _player = player;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.player.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        
        NSString *message = nil;
        
        Entity *spellTarget = self.player.target;
        if ( ! spellTarget )
            spellTarget = self.player;
        else if ( ! spell.targeted )
            spellTarget = self.player;
        BOOL invalidDueToCooldown = NO;
        BOOL canStartCastingSpell = [self.player validateSpell:spell asSource:YES otherEntity:spellTarget message:&message invalidDueToCooldown:&invalidDueToCooldown];
        
        UIImage *spellImage = spell.image;
        //if ( ! canStartCastingSpell )
        //   spellImage = [ImageFactory questionMark];
        
        NSInteger row = idx / SPELLS_PER_ROW;
        NSInteger column = idx % SPELLS_PER_ROW;
        CGRect spellRect = CGRectMake(rect.origin.x + ( SPELL_WIDTH * column ),
                                      rect.origin.y + ( SPELL_HEIGHT * row ), SPELL_WIDTH, SPELL_HEIGHT);
        //PHLog(@"drawing %@ in %f %f %f %f",spellImage,spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
        
//#warning this is here due to emphasis yellow leaving traces when it stops drawing
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextAddRect(context, spellRect);
        //CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        //CGContextFillPath(context);
        // nvm drawing outside specified rect lol
        
        [spellImage drawInRect:spellRect];
                
        // disabled mask
        if ( ! canStartCastingSpell && ! invalidDueToCooldown )
        {
            CGContextSetFillColorWithColor(context,[UIColor disabledSpellColor].CGColor);
            CGRect rectangle = CGRectMake(spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
            CGContextAddRect(context, rectangle);
            CGContextFillPath(context);
        }
        
        if ( spell.isEmphasized )
        {
            [self _drawEmphasisInRect:spellRect spell:spell];
        }
        
        // cooldown clock
        if ( spell.nextCooldownDate )
        {
            double cooldownPercentage = -[[NSDate date] timeIntervalSinceDate:spell.nextCooldownDate] / spell.cooldown.doubleValue;
            [self _drawCooldownClockInRect:spellRect withPercentage:cooldownPercentage];
        }
        else if ( self.player.nextGlobalCooldownDate && self.player.currentGlobalCooldownDuration > 0 )
        {
            double gcdPercentage = -[[NSDate date] timeIntervalSinceDate:self.player.nextGlobalCooldownDate] / self.player.currentGlobalCooldownDuration;
            [self _drawCooldownClockInRect:spellRect withPercentage:gcdPercentage];
        }
        
        idx++;
//#warning crashing here EXC_BAD_ACCESS objc_release (mystery object) when casting lay on hands
        // fixed http://stackoverflow.com/questions/8814718/handling-pointer-to-pointer-ownership-issues-in-arc
    }];
}

static CGFloat const kDashedBorderWidth     = (4.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);
static NSUInteger const kTimeToMoveOneLengthTenthsOfASecond   = (4);

- (void)_drawEmphasisInRect:(CGRect)rect spell:(Spell *)spell
{
    if ( ! _emphasisReferenceDate )
        _emphasisReferenceDate = [NSDate date];
    NSDate *emphasisEndDate = spell.emphasisStopDate;
    if ( ! emphasisEndDate )
        return;
    
    NSDate *now = [NSDate date];
    NSTimeInterval timeRemaining = -[now timeIntervalSinceDate:emphasisEndDate];
    if ( timeRemaining <= 0 )
        return;
    
    NSUInteger modTenthsOfASecond = (NSUInteger)( timeRemaining * 10 ) % 10;
    
    CGFloat kDashedPhase           = (((double)modTenthsOfASecond / (double)kTimeToMoveOneLengthTenthsOfASecond) * kDashedLinesLength[0]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, kDashedBorderWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    
    CGRect emphasisRect = CGRectMake(rect.origin.x + kDashedBorderWidth / 2,
                                     rect.origin.y + kDashedBorderWidth / 2,
                                     rect.size.width - ( kDashedBorderWidth ),
                                     rect.size.height - ( kDashedBorderWidth ));
    CGContextAddRect(context, emphasisRect);
    CGContextStrokePath(context);
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
#warning TODO SIGABRT Assertion failed: (CGFloatIsValid(x) && CGFloatIsValid(y)), function void CGPathAddLineToPoint(CGMutablePathRef, const CGAffineTransform *, CGFloat, CGFloat), file Paths/CGPath.cc, line 265. \
    x	CGFloat	3.0858984037676233E-314	3.0858984037676233E-314 \
    y	CGFloat	3.0888696197011086E-314	3.0888696197011086E-314 \
    rect	CGRect	origin=(x=0, y=90) size=(width=45, height=45) \
    unitPoint	CGPoint	(x=NaN, y=0) \
    midPoint	CGPoint	(x=3.0852801497810434E-314, y=NaN)
    if ( isnan(mysteryPoint.x) || isnan(mysteryPoint.y) )
    {
        NSLog(@"cooldown clock nan bug happened");
        return;
    }
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    //NSUInteger spellIndex = ( ( [theTouch locationInView:self].x / SPELL_WIDTH );
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.player.spells.count )
        theSpell = self.player.spells[spellIdx];
    PHLog(@"you began touching %@ (%lu,%lu)",theSpell,row,column);
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    //NSUInteger spellIndex = ( ( [theTouch locationInView:self].x / SPELL_WIDTH );
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.player.spells.count )
        theSpell = self.player.spells[spellIdx];
    PHLog(@"you stopped touching %@ (%lu,%lu)",theSpell,row,column);
    
    if ( self.spellCastAttemptHandler )
        self.spellCastAttemptHandler(theSpell);
}

@end
