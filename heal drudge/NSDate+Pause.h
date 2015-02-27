//
//  NSDate+Pause.h
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Pause)

+ (void)pause;
+ (BOOL)isPaused;
+ (void)unpause;

- (NSTimeInterval)timeIntervalSinceDateMinusPauseTime:(NSDate *)anotherDate;

@end
