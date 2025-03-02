//
//  NSDate+Pause.m
//  pockethealer
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "NSDate+Pause.h"

@implementation NSDate (Pause)

static NSDate *sNSDatePauseDate = 0;
static NSDate *sNSDateLastPauseDate = 0;
static NSDate *sNSDateLastUnpauseDate = 0;
static NSTimeInterval sNSDateLastPauseDuration = 0;
//static NSTimeInterval sCumulativePausedTime = 0;
static BOOL sNSDateHasBeenPaused = NO;

+ (void)pause
{
    if ( sNSDatePauseDate )
        [NSException raise:@"NSDateAlreadyPaused" format:@""];
    sNSDateHasBeenPaused = YES;
    sNSDatePauseDate = [NSDate date];
}

+ (BOOL)isPaused
{
    return ( sNSDatePauseDate != nil );
}

+ (void)unpause
{
    if ( ! sNSDatePauseDate )
        [NSException raise:@"NSDateNotPaused" format:@""];
    //sCumulativePausedTime += [[NSDate date] timeIntervalSinceDate:sNSDatePauseDate];
    sNSDateLastPauseDate = sNSDatePauseDate;
    sNSDateLastUnpauseDate = [NSDate date];
    sNSDateLastPauseDuration = [sNSDateLastUnpauseDate timeIntervalSinceDate:sNSDateLastPauseDate];
    sNSDatePauseDate = nil;
}

- (NSTimeInterval)timeIntervalSinceDateMinusPauseTime:(NSDate *)anotherDate
{
    if ( ! sNSDateHasBeenPaused )
        return [self timeIntervalSinceDate:anotherDate];
    
    NSDate *now = [NSDate date];
    NSTimeInterval realTimeInterval = [now timeIntervalSinceDate:anotherDate];
    NSTimeInterval effectiveTimeInterval = realTimeInterval;
    
    if ( sNSDatePauseDate )
    {
        NSComparisonResult anotherDateToPauseDate = [anotherDate compare:sNSDatePauseDate];
        NSComparisonResult selfToPauseDate = [self compare:sNSDatePauseDate];
        
        // if parameters straddle the current pause, subtract the entire current pause time
        // self --- | pause | --- another
        if ( anotherDateToPauseDate == NSOrderedDescending
            && selfToPauseDate == NSOrderedAscending )
        {
            effectiveTimeInterval += [now timeIntervalSinceDate:sNSDatePauseDate];
        }
        // another ---| pause | --- self
        else if ( selfToPauseDate == NSOrderedDescending
                 && anotherDateToPauseDate == NSOrderedAscending )
        {
            effectiveTimeInterval -= [now timeIntervalSinceDate:sNSDatePauseDate];
        }
    }
    if ( sNSDateLastPauseDate )
    {
        NSComparisonResult anotherDateToLastPauseDate = [anotherDate compare:sNSDateLastPauseDate];
        NSComparisonResult selfToLastPauseDate = [self compare:sNSDateLastPauseDate];
        
        // self --- | last pause | --- another
        if ( anotherDateToLastPauseDate == NSOrderedDescending
            && selfToLastPauseDate == NSOrderedAscending )
        {
            effectiveTimeInterval -= sNSDateLastPauseDuration;
        }
        // another --- | lastPause | --- self
        else if ( selfToLastPauseDate == NSOrderedDescending
                 && anotherDateToLastPauseDate == NSOrderedAscending )
        {
            effectiveTimeInterval += sNSDateLastPauseDuration;
        }
    }
    //PHLogV(@"EFFECTIVE TIME: %0.2f = %0.2f - %0.2f",effectiveTimeInterval,realTimeInterval,(realTimeInterval - effectiveTimeInterval));
    return effectiveTimeInterval;
}

@end
