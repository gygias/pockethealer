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

- (void)drawRect:(CGRect)rect {
    
    Enemy *theEnemy = self.encounter.enemies.firstObject;
    UIBezierPath *path = [theEnemy roomPathWithRect:rect];
    
    [[UIColor whiteColor] setStroke];
    [path stroke];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self.encounter.enemies enumerateObjectsUsingBlock:^(Entity *raider, NSUInteger idx, BOOL *stop) {
        
        CGPoint effectiveLocation = raider.location;
        
        NSString *enemyText = @"☠";
        CGPoint centeredTextLocation = CGPointMake(effectiveLocation.x - [enemyText sizeWithAttributes:attributes].width / 2,
                                                   effectiveLocation.y - [enemyText sizeWithAttributes:attributes].height / 2);
        [enemyText drawAtPoint:centeredTextLocation withAttributes:attributes];
    }];
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *raider, NSUInteger idx, BOOL *stop) {
        
        CGPoint effectiveLocation = raider.location;
        
        if ( self.encounter.player.target == raider )
            [self _drawTargetingCrossAt:effectiveLocation];
        
        if ( raider == self.encounter.player )
        {
            NSString *playerText = @"☺";
            CGPoint centeredTextLocation = CGPointMake(effectiveLocation.x - [playerText sizeWithAttributes:attributes].width / 2,
                                                       effectiveLocation.y - [playerText sizeWithAttributes:attributes].height / 2);
            [playerText drawAtPoint:centeredTextLocation withAttributes:attributes];
        }
        else
        {
            UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:effectiveLocation radius:2 startAngle:0 endAngle:2*M_PI clockwise:NO];
            [raider.hdClass.classColor setFill];
            [arc fill];
        }
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
