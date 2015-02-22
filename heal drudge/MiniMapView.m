//
//  MiniMapView.m
//  heal drudge
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MiniMapView.h"

#import "Raid.h"

@implementation MiniMapView

@synthesize encounter = _encounter;

- (void)setEncounter:(Encounter *)encounter
{
    _encounter = encounter;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    Enemy *theEnemy = self.encounter.enemies.firstObject;
    return theEnemy.roomSize;
}

#define LAST_AOE_DRAW_THRESHOLD 2.0

- (void)drawRect:(CGRect)rect {
    
    Enemy *theEnemy = self.encounter.enemies.firstObject;
    UIBezierPath *path = [theEnemy roomPathWithRect:rect];
    
    [[UIColor whiteColor] setStroke];
    [path stroke];
    
    NSDictionary *enemyAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSDictionary *playerAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                      NSFontAttributeName : [UIFont systemFontOfSize:5]};
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *raider, NSUInteger idx, BOOL *stop) {
        
        CGPoint effectiveLocation = raider.location;
        
        if ( self.encounter.player.target == raider )
            [self _drawTargetingCrossAt:effectiveLocation];
        
        if ( raider == self.encounter.player )
        {
            NSString *playerText = @"☺";
            CGPoint centeredTextLocation = CGPointMake(effectiveLocation.x - [playerText sizeWithAttributes:playerAttributes].width / 2,
                                                       effectiveLocation.y - [playerText sizeWithAttributes:playerAttributes].height / 2);
            [playerText drawAtPoint:centeredTextLocation withAttributes:playerAttributes];
        }
        else
        {
            UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:effectiveLocation radius:2 startAngle:0 endAngle:2*M_PI clockwise:NO];
            [raider.hdClass.classColor setFill];
            [arc fill];
        }
        
        if ( raider.lastHitAOEDate )
        {
            NSTimeInterval timeSinceLastAOE = [[NSDate date] timeIntervalSinceDate:raider.lastHitAOEDate];
            if ( timeSinceLastAOE >= LAST_AOE_DRAW_THRESHOLD )
            {
                raider.lastHitAOESpell = nil;
                return;
            }
            
            double percentage = 1 - timeSinceLastAOE / LAST_AOE_DRAW_THRESHOLD;
            double radius = ( 1 - percentage ) * raider.lastHitAOESpell.hitRange.doubleValue;
            
            UIColor *emanationColor = ( raider.lastHitAOESpell.spellType != DetrimentalEffect ? [UIColor greenColor] : [UIColor redColor] );
            UIColor *emanationColorAlpha = [emanationColor colorWithAlphaComponent:percentage];
            [emanationColorAlpha setStroke];
            [[UIBezierPath bezierPathWithArcCenter:raider.location radius:raider.lastHitAOESpell.hitRange.doubleValue startAngle:0 endAngle:2*M_PI clockwise:NO] stroke];
            [emanationColorAlpha setFill];
            [[UIBezierPath bezierPathWithArcCenter:raider.location radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO] fill];
        }
    }];
    
    [self.encounter.enemies enumerateObjectsUsingBlock:^(Entity *raider, NSUInteger idx, BOOL *stop) {
        
        CGPoint effectiveLocation = raider.location;
        
        NSString *enemyText = @"☠";
        CGPoint centeredTextLocation = CGPointMake(effectiveLocation.x - [enemyText sizeWithAttributes:enemyAttributes].width / 2,
                                                   effectiveLocation.y - [enemyText sizeWithAttributes:enemyAttributes].height / 2);
        [enemyText drawAtPoint:centeredTextLocation withAttributes:enemyAttributes];
    }];
}

#define TARGETING_CROSS_WIDTH 2
#define TARGETING_CROSS_HEIGHT 6
#define TARGETING_CROSS_WIDTH_OFFSET (TARGETING_CROSS_WIDTH / 2)
#define TARGETING_CROSS_HEIGHT_OFFSET (TARGETING_CROSS_HEIGHT / 2)

- (void)_drawTargetingCrossAt:(CGPoint)location
{
    [[UIColor yellowColor] setFill];
    CGRect uprightRect = CGRectMake(location.x - TARGETING_CROSS_WIDTH_OFFSET,
                                    location.y - TARGETING_CROSS_HEIGHT_OFFSET,
                                    TARGETING_CROSS_WIDTH,
                                    TARGETING_CROSS_HEIGHT);
    [[UIBezierPath bezierPathWithRect:uprightRect] fill];
    CGRect horizontalRect = CGRectMake(location.x - TARGETING_CROSS_HEIGHT_OFFSET,
                                       location.y - TARGETING_CROSS_WIDTH_OFFSET,
                                       TARGETING_CROSS_HEIGHT,
                                       TARGETING_CROSS_WIDTH);
    [[UIBezierPath bezierPathWithRect:horizontalRect] fill];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    CGPoint thePoint = [theTouch locationInView:self];
    
    [self.encounter.player moveToLocation:thePoint];
}

@end
