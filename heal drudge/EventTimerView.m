//
//  EventTimerView.m
//  heal drudge
//
//  Created by david on 1/31/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "EventTimerView.h"

#import "Spell.h"

@implementation EventTimerView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    __block CGFloat yOffset = 0;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.spellEvents enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
        NSDictionary *dateDict = [[eventDict allKeys] lastObject];
        Spell *spell = [eventDict objectForKey:dateDict];
        
        CGSize size = [spell.name sizeWithAttributes:attributes];
        
        NSDate *scheduledDate = dateDict[@"scheduledDate"];
        NSDate *fireDate = dateDict[@"fireDate"];
        NSTimeInterval timeUntilEvent = -[[NSDate date] timeIntervalSinceDate:fireDate];
        //NSTimeInterval timeSinceScheduled = [[NSDate date] timeIntervalSinceDate:scheduledDate];
        NSTimeInterval timeBetweenScheduleAndEvent = [fireDate timeIntervalSinceDate:scheduledDate];
        double percentFill = timeUntilEvent / timeBetweenScheduleAndEvent;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rectangle = CGRectMake( rect.origin.x,
                                      rect.origin.y + yOffset,
                                      rect.size.width * percentFill,
                                      size.height);
        CGContextAddRect(context, rectangle);
        CGContextSetStrokeColorWithColor(context,
                                         [UIColor whiteColor].CGColor);
        CGContextStrokePath(context);
        CGContextSetFillColorWithColor(context,
                                       [UIColor redColor].CGColor);
        CGContextFillRect(context, rectangle);
        
        CGRect aRect = CGRectMake(rect.origin.x, rect.origin.y + yOffset, size.width, size.height);
        [spell.name drawInRect:aRect withAttributes:attributes];
        yOffset += size.height;
    }];
}

- (void)addSpellEvent:(Spell *)spell date:(NSDate *)date
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( ! self.spellEvents )
            self.spellEvents = [NSMutableArray new];
        
        __block NSUInteger insertIdx = 0;
        NSTimeInterval timeUntilThisEvent = -[[NSDate date] timeIntervalSinceDate:date];
        [self.spellEvents enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
            insertIdx = idx;
            NSDictionary *dateDict = [[eventDict allKeys] lastObject];
            NSDate *fireDate = dateDict[@"fireDate"];
            NSTimeInterval timeUntilAEvent = -[[NSDate date] timeIntervalSinceDate:fireDate];
            if ( timeUntilAEvent < timeUntilThisEvent )
                *stop = YES;
        }];
        
        NSDictionary *keyDict = @{ @"scheduledDate" : [NSDate date], @"fireDate" : date };
        NSDictionary *eventDict = @{ keyDict : spell };
        if ( [self.spellEvents containsObject:eventDict] )
            [NSException raise:@"EventTimerViewAlreadyHasEvent" format:@"something happened: %@ vs %@",eventDict,self.spellEvents];
        [(NSMutableArray *)self.spellEvents insertObject:eventDict atIndex:insertIdx];
        
        NSTimeInterval timeUntilEvent = -[[NSDate date] timeIntervalSinceDate:date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeUntilEvent * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [(NSMutableArray *)self.spellEvents removeObject:eventDict];
        });
    });
}

@end
