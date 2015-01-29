//
//  AlertTextView.m
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AlertTextView.h"

#import "AlertText.h"

@implementation AlertTextView

@synthesize alertTexts = _alertTexts;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self.alertTexts enumerateObjectsUsingBlock:^(AlertText *obj, NSUInteger idx, BOOL *stop) {
        
        UIColor *drawColor = [UIColor redColor];
#warning TODO i've crashed here sending -[CALayer startDate] to obj.startDate
        drawColor = [drawColor colorWithAlphaComponent:( ( 1 - [[NSDate date] timeIntervalSinceDate:obj.startDate] / obj.duration ) )];
        NSDictionary *attributes = @{ NSForegroundColorAttributeName : drawColor };
        CGSize alertTextSize = [obj.text sizeWithAttributes:attributes];
        CGRect alertTextRect = CGRectMake(rect.origin.x, rect.origin.y + ( alertTextSize.height * idx ), rect.size.width, rect.size.height);
        [obj.text drawInRect:alertTextRect withAttributes:attributes];
    }];
}

- (void)addAlertText:(AlertText *)alertText
{
    if ( ! _alertTexts )
        _alertTexts = [NSMutableArray new];
    [(NSMutableArray *)_alertTexts addObject:alertText];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(alertText.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(NSMutableArray *)_alertTexts removeObject:alertText];
    });
}

@end
