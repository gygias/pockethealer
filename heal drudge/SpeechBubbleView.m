//
//  SpeechBubbleView.m
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SpeechBubbleView.h"

@implementation SpeechBubbleView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
static CGFloat sSpeechBubbleInset = 10;
- (void)drawRect:(CGRect)rect {
    CGRect contentFrame = self.referenceView.frame;
    //contentFrame.size.width = 225;
    //NSArray *constraints = [self constraints];
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGRect boundingBox = CGContextGetClipBoundingBox(context);
//    CGContextSetFillColorWithColor(context, [[UIColor purpleColor] colorWithAlphaComponent:0.25].CGColor);
//    CGContextAddRect(context, rect);
//    CGContextFillPath(context);
//    CGRect lolRect = CGRectMake(50, 50, 100, 100);
//    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor purpleColor]};
//    [@"lollercopters" drawAtPoint:lolRect.origin withAttributes:attributes];
//    lolRect = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width, contentFrame.size.height);
    //[@"lollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopterslollercopters" drawAtPoint:lolRect.origin withAttributes:attributes];
    
    CGContextSetFillColorWithColor(context, [UIColor speechBubbleColor].CGColor);
    CGContextAddArc(context, contentFrame.origin.x + sSpeechBubbleInset, contentFrame.origin.y + sSpeechBubbleInset, sSpeechBubbleInset, M_PI, 3 * M_PI_2, NO);
    CGContextAddLineToPoint(context, contentFrame.origin.x + contentFrame.size.width - sSpeechBubbleInset, contentFrame.origin.y);
    CGContextAddArc(context, contentFrame.origin.x + contentFrame.size.width - sSpeechBubbleInset, contentFrame.origin.y + sSpeechBubbleInset, sSpeechBubbleInset, 3 * M_PI_2, 2 * M_PI, NO);
    CGContextAddLineToPoint(context, contentFrame.origin.x + contentFrame.size.width, contentFrame.origin.y + contentFrame.size.height - sSpeechBubbleInset);
    CGContextAddArc(context, contentFrame.origin.x + contentFrame.size.width - sSpeechBubbleInset, contentFrame.origin.y + contentFrame.size.height - sSpeechBubbleInset, sSpeechBubbleInset, 0, M_PI_2, NO);
    CGContextAddLineToPoint(context, contentFrame.origin.x + sSpeechBubbleInset, contentFrame.origin.y + contentFrame.size.height);
    CGContextAddArc(context, contentFrame.origin.x + sSpeechBubbleInset, contentFrame.origin.y + contentFrame.size.height - sSpeechBubbleInset, sSpeechBubbleInset, M_PI_2, M_PI, NO);
    CGContextFillPath(context);
    
    // draw the origin portion
    CGPoint firstPoint;
    BOOL originIsAbove = NO;
    CGFloat midpointBetweenBubbleAndOrigin;
    if ( self.bubbleOrigin.y < contentFrame.origin.y )
    {
        firstPoint = CGPointMake(contentFrame.origin.x + contentFrame.size.width / 2, contentFrame.origin.y);
        originIsAbove = YES;
        midpointBetweenBubbleAndOrigin = ( contentFrame.origin.y + self.bubbleOrigin.y ) / 2;
    }
    else
    {
        firstPoint = CGPointMake(contentFrame.origin.x + contentFrame.size.width / 2, contentFrame.origin.y + contentFrame.size.height);
        midpointBetweenBubbleAndOrigin = (( contentFrame.origin.y + contentFrame.size.height ) + self.bubbleOrigin.y ) / 2;
    }
    
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    CGPoint secondPoint = CGPointMake(firstPoint.x + 40, firstPoint.y);
    CGContextAddLineToPoint(context, secondPoint.x, secondPoint.y);
    CGPoint controlPointOne = CGPointMake( self.bubbleOrigin.x, midpointBetweenBubbleAndOrigin);
    CGPoint controlPointTwo = CGPointMake( secondPoint.x, secondPoint.y + ( originIsAbove ? -20 : 20 ));
    //CGContextAddCurveToPoint(context, controlPointOne.x, controlPointOne.y, controlPointTwo.x, controlPointTwo.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    CGContextAddQuadCurveToPoint(context, controlPointTwo.x, controlPointTwo.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    //controlPointOne = CGPointMake( firstPoint.x - 5, firstPoint.y + 5);
    //controlPointTwo = CGPointMake(( firstPoint.x + self.bubbleOrigin.x ) / 2 - 10, ( firstPoint.y + self.bubbleOrigin.y ) / 2 - 10);
    //CGContextAddCurveToPoint(context, controlPointTwo.x - 10, controlPointTwo.y - 10, controlPointOne.x, controlPointOne.y, firstPoint.x, firstPoint.y);
    controlPointTwo = CGPointMake( secondPoint.x - 10, secondPoint.y + ( originIsAbove ? -20 : 20 ));
    CGContextAddQuadCurveToPoint(context, controlPointTwo.x, controlPointTwo.y, firstPoint.x, firstPoint.y);
    CGContextSetFillColorWithColor(context, [UIColor speechBubbleColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    BOOL drawControlPoints = NO;
    if ( drawControlPoints )
    {
        CGContextAddArc(context, controlPointOne.x, controlPointOne.y, 3, 0, 2 * M_PI, NO);
        CGContextAddArc(context, controlPointTwo.x, controlPointTwo.y, 3, 0, 2 * M_PI, NO);
        CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
        CGContextFillPath(context);
    }
    
//    CGContextAddArc(context, rect.origin.x + rect.size.width - sSpeechBubbleInset, rect.origin.y + sSpeechBubbleInset, sSpeechBubbleInset, 0.0, M_PI * 2, YES);
//    CGContextFillPath(context);
//    CGContextAddArc(context, rect.origin.x + rect.size.width - sSpeechBubbleInset, rect.origin.y + rect.size.height - sSpeechBubbleInset, sSpeechBubbleInset, 0.0, M_PI * 2, YES);
//    CGContextFillPath(context);
//    CGContextAddArc(context, rect.origin.x + sSpeechBubbleInset, rect.origin.y + rect.size.height - sSpeechBubbleInset, sSpeechBubbleInset, 0.0, M_PI * 2, YES);
//    CGContextFillPath(context);
//    CGRect innerRect = CGRectMake(rect.origin.x + sSpeechBubbleInset,
//                                  rect.origin.y,
//                                  rect.size.width - 2 * sSpeechBubbleInset,
//                                  rect.size.height);
//    CGContextAddRect(context, innerRect);
//    CGContextFillPath(context);
//    
//    CGRect innerRect2 = CGRectMake(rect.origin.x,
//                                   rect.origin.y + sSpeechBubbleInset,
//                                   rect.size.width,
//                                   rect.size.height - 2 * sSpeechBubbleInset);
//    CGContextAddRect(context, innerRect2);
//    CGContextFillPath(context);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end
