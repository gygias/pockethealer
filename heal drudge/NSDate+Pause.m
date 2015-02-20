//
//  NSDate+Pause.m
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "NSDate+Pause.h"

@implementation NSDate (Pause)

static NSDate *sNSDatePauseDate = 0;
static NSDate *sNSLastPauseDate = 0;
static NSDate *sNSDatePauseStopDate = 0;
static NSTimeInterval sCumulativePausedTime = 0;

+ (void)pause
{
    sNSDatePauseDate = [NSDate date];
}

+ (void)unpause
{
    sCumulativePausedTime += [[NSDate date] timeIntervalSinceDate:sNSDatePauseDate];
    sNSDatePauseDate = nil;
}

- (NSTimeInterval)timeIntervalSinceDateMinusPauseTime:(NSDate *)anotherDate
{
    return [self timeIntervalSinceDate:anotherDate];
//    if ( sNSDatePauseDate )
//    {
//        // if i am before the pause, return the time between me and the pause
//        if ( [self compare:sNSDatePauseDate] == NSOrderedAscending )
//            return [sNSDatePauseDate timeIntervalSinceDate:self];
//        // if i am on or after the pause, return 0
//        else
//            return 0;
//    }
//    NSTimeInterval realTimeInterval = [self timeIntervalSinceDate:anotherDate];
//    return realTimeInterval - sCumulativePausedTime;
}

@end
