//
//  MeterView.m
//  heal drudge
//
//  Created by david on 2/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MeterView.h"

@implementation MeterView

#define METER_DEFAULT_LINES 5.0
#define METER_LINE_HEIGHT 12.0
#define METER_INSET 1.0

- (void)drawRect:(CGRect)rect
{
    CGFloat lineHeight = METER_LINE_HEIGHT;
    
    NSMutableArray *entitiesToDraw = [NSMutableArray new];
    
    UIFont *textFont = [UIFont systemFontOfSize:8];
    
    SEL selector = NULL;
    if ( self.mode == HealingDoneMode )
        selector = @selector(totalHealingForEntity:);
    else if ( self.mode == OverhealingMode )
        selector = @selector(totalOverhealForEntity:);
    else if ( self.mode == HealingTakenMode )
        selector = @selector(totalHealingTakenForEntity:);
    else if ( self.mode == DamageDoneMode )
        selector = @selector(totalDamageForEntity:);
    else
        return;
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        NSNumber *value = [self.encounter.combatLog performSelector:selector withObject:player];
        if ( value.doubleValue ) // TODO this sorting should probably be done on encounter queue
        {
            NSUInteger insertIdx = 0;
            for ( NSDictionary *existingEntityDict in entitiesToDraw )
            {
                if ( [existingEntityDict[@"v"] compare:value] == NSOrderedAscending )
                    break;
                insertIdx++;
            }
            [entitiesToDraw insertObject:@{@"e":player,@"v":value} atIndex:insertIdx];
        }
        if ( entitiesToDraw.count == METER_DEFAULT_LINES )
            *stop = YES;
    }];
    
    NSNumber *highestValue = nil;
    NSNumber *totalHealing = nil;
    if ( entitiesToDraw.count )
    {
        highestValue = ((NSDictionary *)[entitiesToDraw firstObject])[@"v"];
        totalHealing = [self.encounter.combatLog totalHealingForRaid];
    }
    
    NSUInteger idx = 0;
    for ( ; idx == 0 || ( idx < entitiesToDraw.count && idx < METER_DEFAULT_LINES ); idx++ )
    {
        CGRect myRect;
        if ( idx == 0 )
            myRect = rect;
        else
            myRect = CGRectMake(rect.origin.x + METER_INSET,
                                rect.origin.y + METER_INSET + idx * lineHeight,
                                rect.size.width - METER_INSET * 2,
                                lineHeight - METER_INSET * 2);
        UIColor *drawColor = [[UIColor blueColor] colorWithAlphaComponent:.75];
        [drawColor setFill];
        [[UIBezierPath bezierPathWithRect:myRect] fill];
        
        if ( idx == 0 )
        {
            NSString *modeDescription = nil;
            if ( self.mode == HealingDoneMode )
                modeDescription = @"Healing Done";
            else if ( self.mode == OverhealingMode )
                modeDescription = @"Overhealing Done";
            else if ( self.mode == HealingTakenMode )
                modeDescription = @"Healing Taken";
            else if ( self.mode == DamageDoneMode )
                modeDescription = @"Damage Done";
            NSDictionary *titleAttributes = @{NSFontAttributeName : textFont,
                                              NSForegroundColorAttributeName : [UIColor whiteColor]};
            CGSize textSize = [modeDescription sizeWithAttributes:titleAttributes];
            [modeDescription drawInRect:myRect withAttributes:titleAttributes];
            
            CGPoint titleBarDelimiter0 = CGPointMake(myRect.origin.x + METER_INSET,
                                                     myRect.origin.y + METER_INSET + textSize.height);
            CGPoint titleBarDelimiter1 = CGPointMake(myRect.origin.x + rect.size.width - 2 * METER_INSET,
                                                     myRect.origin.y + METER_INSET + textSize.height);
            UIBezierPath *titleBarDelimiter = [UIBezierPath bezierPath];
            [titleBarDelimiter moveToPoint:titleBarDelimiter0];
            [titleBarDelimiter addLineToPoint:titleBarDelimiter1];
            //drawColor = [UIColor blackColor];
            //[drawColor setStroke];
            [titleBarDelimiter stroke];
            
            continue;
        }
        
        NSDictionary *entityDict = [entitiesToDraw objectAtIndex:idx - 1];
        Entity *entity = entityDict[@"e"];
        NSNumber *value = entityDict[@"v"];
        
        double percentage = highestValue.doubleValue ? ( value.doubleValue / highestValue.doubleValue ) : 1.0;
        CGRect myBarRect = CGRectMake(rect.origin.x + METER_INSET,
                                      rect.origin.y + METER_INSET + idx * lineHeight,
                                      ( rect.size.width - METER_INSET * 2 ) * percentage,
                                      lineHeight - METER_INSET * 2);
        drawColor = [entity.hdClass classColor];
        [drawColor setFill];
        [[UIBezierPath bezierPathWithRect:myBarRect] fill];
        
        //CGSize nameSize = [entity.name sizeWithAttributes:nil];
        [entity.name drawInRect:myRect withAttributes:@{NSFontAttributeName : textFont}];
        
        double percentageOfTotalHealing = totalHealing ? ( value.doubleValue / totalHealing.doubleValue * 100 ) : 0;
        NSString *valueString = [NSString stringWithFormat:@"%0.0f (%0.0f%%)",value.doubleValue,percentageOfTotalHealing];
        CGSize valueSize = [valueString sizeWithAttributes:nil];
        CGRect myValueRect = CGRectMake(rect.origin.x + rect.size.width - METER_INSET * 2 - valueSize.width,
                                        rect.origin.y + METER_INSET + idx * lineHeight,
                                        valueSize.width,
                                        lineHeight);
        [valueString drawInRect:myValueRect withAttributes:@{NSFontAttributeName : textFont}];
    }
}

@end
