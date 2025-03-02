//
//  TouchDemoView.m
//  pockethealer
//
//  Created by david on 3/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "TouchDemoView.h"

@interface TouchDemoView ()

@property NSDate *lastTouchDate;
@property CGPoint currentPoint;
@property CGPoint movingToPoint;
@property NSDate *moveStartDate;

@end

@implementation TouchDemoView

#define FINGER_RADIUS 10.0
#define TOUCH_DURATION 1.0
#define LOL_DURATION 0.5
#define TOUCH_RADIUS 3.0

- (void)drawRect:(CGRect)rect
{
    CGFloat xDelta = 0;
    CGFloat yDelta = 0;
    if ( self.moveStartDate )
    {
        NSTimeInterval movingFor = [[NSDate date] timeIntervalSinceDate:self.moveStartDate];
        if ( movingFor >= MOVE_DURATION )
        {
            self.moveStartDate = nil;
            self.currentPoint = self.movingToPoint;
            //NSLog(@"end move: %@",PointString(self.currentPoint));
        }
        else
        {
            double moveProgress = movingFor / MOVE_DURATION;
            xDelta = ( self.movingToPoint.x - self.currentPoint.x ) * moveProgress;
            yDelta = ( self.movingToPoint.y - self.currentPoint.y ) * moveProgress;
        }
    }
    CGPoint interpolatedLocation = CGPointMake(self.currentPoint.x + xDelta, self.currentPoint.y + yDelta);
    
    UIBezierPath *fingerPath = [UIBezierPath bezierPathWithArcCenter:interpolatedLocation
                                                              radius:FINGER_RADIUS
                                                          startAngle:0
                                                            endAngle:2*M_PI
                                                           clockwise:NO];
    [[[UIColor whiteColor] colorWithAlphaComponent:0.75] setFill];
    [fingerPath fill];
    
    if ( self.lastTouchDate )
    {
        NSTimeInterval touchingFor = [[NSDate date] timeIntervalSinceDate:self.lastTouchDate];
        if ( touchingFor >= TOUCH_DURATION )
            self.lastTouchDate = nil;
        else
        {
            double touchProgress = touchingFor / TOUCH_DURATION;
            CGFloat touchRadius = FINGER_RADIUS + ( touchProgress * TOUCH_RADIUS );
            UIBezierPath *touchPath = [UIBezierPath bezierPathWithArcCenter:interpolatedLocation
                                                                     radius:touchRadius
                                                                 startAngle:0
                                                                   endAngle:2*M_PI
                                                                  clockwise:NO];
            [[UIColor whiteColor] setStroke];
            [touchPath stroke];
            
//            if ( touchingFor < LOL_DURATION )
//            {
//                [@"lol" drawAtPoint:interpolatedLocation withAttributes:nil];
//            }
        }
    }
}

- (void)doTouch
{
    self.lastTouchDate = [NSDate date];
}

- (void)moveTo:(CGPoint)point
{
    self.movingToPoint = point;
    self.moveStartDate = [NSDate date];
}

@end
