//
//  MeterView.m
//  heal drudge
//
//  Created by david on 2/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MeterView.h"

@interface MeterView ()

@property NSUInteger currentTopLine;
@property NSUInteger currentLines;

@end

@implementation MeterView

//#define METER_DEFAULT_LINES 5.0
#define METER_LINE_HEIGHT 12.0
#define METER_INSET 1.0

@synthesize mode = _mode;

- (void)setMode:(MeterMode)mode
{
    _mode = mode;
    State *state = [State sharedState];
    state.meterMode = mode;
    [state writeState];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIPanGestureRecognizer *swipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_swipe:)];
        //swipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tap:)];
        self.gestureRecognizers = @[ swipe, tap ];
    });
}

- (void)_swipe:(UIGestureRecognizer *)recognizer
{
    if ( [recognizer isKindOfClass:[UIPanGestureRecognizer class]] )
    {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        CGPoint translation =[panRecognizer translationInView:self];
        if ( panRecognizer.state == UIGestureRecognizerStateBegan )
        {
            //PHLogV(@"swipe began: %@: %@",recognizer,PointString(translation));
        }
        else if ( panRecognizer.state == UIGestureRecognizerStateChanged )
        {
            //PHLogV(@"swipe changed: %@: %@",recognizer,PointString(translation));
            CGFloat delta = translation.y / METER_LINE_HEIGHT;
            if ( delta > self.lastRect.size.height / METER_LINE_HEIGHT )
                delta = self.lastRect.size.height / METER_LINE_HEIGHT;
            if ( self.currentTopLine + delta < 0 )
            {
                //PHLogV(@"-- 1");
                self.currentTopLine = 0;
            }
            else if ( self.currentTopLine + delta > self.currentLines - ( self.lastRect.size.height / METER_LINE_HEIGHT - 1 ) )
            {
                //PHLogV(@"-- 2");
                self.currentTopLine = self.currentLines - self.currentTopLine;
            }
            else if ( self.currentTopLine + delta > self.currentLines )
            {
                //PHLogV(@"-- 4");
                if ( self.currentLines >= self.lastRect.size.height / METER_LINE_HEIGHT )
                {
                    //PHLogV(@"top line = %u = %u - %u",self.currentLines - self.currentTopLine,self.currentLines,self.currentTopLine);
                    self.currentTopLine = self.currentLines - self.currentTopLine;
                }
                else
                {
                    //PHLogV(@"top line = 0");
                    self.currentTopLine = 0;
                }
            }
            else
            {
                //PHLogV(@"-- 3");
                self.currentTopLine += delta;
            }
        }
        else if ( panRecognizer.state == UIGestureRecognizerStateEnded )
        {
            //PHLogV(@"swipe ended: %@: %@",recognizer,PointString(translation));
        }
        else
        {
            //PHLogV(@"swipe ???: %@",recognizer);
        }
    }
}

- (void)_tap:(UIGestureRecognizer *)recognizer
{
    if ( [recognizer isKindOfClass:[UITapGestureRecognizer class]] )
    {
        UITapGestureRecognizer *panRecognizer = (UITapGestureRecognizer *)recognizer;
        if ( panRecognizer.state == UIGestureRecognizerStateBegan )
        {
            //PHLogV(@"tap began: %@",recognizer);
        }
        else if ( panRecognizer.state == UIGestureRecognizerStateChanged )
        {
            //PHLogV(@"tap changed: %@",recognizer);
        }
        else if ( panRecognizer.state == UIGestureRecognizerStateEnded )
        {
            //PHLogV(@"tap ended: %@",recognizer);
            if ( self.touchedHandler )
                self.touchedHandler();
        }
        else
        {
            //PHLogV(@"tap ???: %@",recognizer);
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    self.lastRect = rect;
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
    else if ( self.mode == DamageTakenMode )
        selector = @selector(totalDamageTakenForEntity:);
    else
        return;
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        // performselector throws a 'may leak' warning under ARC
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        IMP imp = [self.encounter.combatLog methodForSelector:selector];
        NSNumber *(*function)(id, SEL, Entity*) = (void *)imp;
        NSNumber *value = function(self.encounter.combatLog,selector,player);
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
        //if ( entitiesToDraw.count == METER_DEFAULT_LINES )
        //    *stop = YES;
    }];
    
    NSNumber *highestValue = nil;
    NSNumber *totalHealing = nil;
    if ( entitiesToDraw.count )
    {
        highestValue = ((NSDictionary *)[entitiesToDraw firstObject])[@"v"];
        totalHealing = [self.encounter.combatLog totalHealingForRaid];
    }
    
    NSUInteger idx = 0;
    NSUInteger entitiesBase;
    //NSInteger rowsHereOrBelow = entitiesToDraw.count - self.currentTopLine - idx;
    if ( entitiesToDraw.count <= self.currentTopLine )
    {
        //PHLogV(@"1");
        entitiesBase = 0;
    }
    else if ( entitiesToDraw.count - self.currentTopLine > self.lastRect.size.height / METER_LINE_HEIGHT )
    {
        //PHLogV(@"2");
        entitiesBase = self.currentTopLine;
    }
    else if ( entitiesToDraw.count - self.lastRect.size.height / METER_LINE_HEIGHT > 0 )
    {
        //PHLogV(@"3");
        entitiesBase = entitiesToDraw.count - self.lastRect.size.height / METER_LINE_HEIGHT;
    }
    else
    {
        //PHLogV(@"4");
        entitiesBase = 0;
    }
    
//    PHLogV(@"c %u l %u, will draw %u through %u (%u vs %u)",self.currentTopLine,
//           self.currentLines,
//           idx + entitiesBase,
//          (entitiesToDraw.count + 1) < (self.currentLines)?(entitiesToDraw.count + 1):self.currentLines,
//          (entitiesBase < entitiesToDraw.count + 1),
//           self.currentLines);
    
    self.currentLines = entitiesToDraw.count;
    for ( ; idx == 0 || ( idx + entitiesBase < entitiesToDraw.count + 1 && idx + entitiesBase < self.currentLines ); idx++ )
    {
        CGRect myRect;
        if ( idx == 0 )
            myRect = rect;
        else
            myRect = CGRectMake(rect.origin.x + METER_INSET,
                                rect.origin.y + METER_INSET + idx * lineHeight,
                                rect.size.width - METER_INSET * 2,
                                lineHeight - METER_INSET * 2);
        UIColor *drawColor = [[UIColor blueColor] colorWithAlphaComponent:.5];
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
            else if ( self.mode == DamageTakenMode )
                modeDescription = @"Damage Taken";
            else
                modeDescription = @"???";
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
        
        self.currentLines = entitiesToDraw.count;
        NSUInteger drawIdx = idx + entitiesBase - 1;
        //NSLog(@"current lines: %lu, top line: %lu (%lu)",(unsigned long)self.currentLines,(unsigned long)self.currentTopLine,(unsigned long)(self.currentLines - self.currentTopLine));
        NSDictionary *entityDict = [entitiesToDraw objectAtIndex:drawIdx];
        Entity *entity = entityDict[@"e"];
        NSNumber *value = entityDict[@"v"];
        
        double percentage = highestValue.doubleValue ? ( value.doubleValue / highestValue.doubleValue ) : 1.0;
        CGRect myBarRect = CGRectMake(rect.origin.x + METER_INSET,
                                      rect.origin.y + METER_INSET + idx * lineHeight,
                                      ( rect.size.width - METER_INSET * 2 ) * percentage,
                                      lineHeight - METER_INSET * 2);
        [self drawGradientFromPoint:rect.origin
                            toPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)
                         startColor:entity.hdClass.classColor
                           endColor:[UIColor darkGrayColor]
                       clippingPath:CGPathCreateWithRect(myBarRect, NULL)];
        
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

//-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    id hitView = [super hitTest:point withEvent:event];
//    if (hitView == self && self.touchedHandler)
//        self.touchedHandler();
//    return hitView;
//}

@end
