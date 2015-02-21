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
    
    [@"☠" drawAtPoint:theEnemy.location withAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *raider, NSUInteger idx, BOOL *stop) {
        UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:raider.location radius:2 startAngle:0 endAngle:2*M_PI clockwise:NO];
        [raider.hdClass.classColor setFill];
        [arc fill];
    }];
}

@end
