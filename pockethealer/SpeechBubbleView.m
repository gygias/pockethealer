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
    
    [self drawRoundedRectangleInRect:contentFrame color:[UIColor speechBubbleColor] radius:sSpeechBubbleInset];
    
    // draw the origin portion
    CGPoint firstPoint;
    BOOL originIsAbove = NO;
    BOOL originIsRight = NO;
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
    if ( self.bubbleOrigin.x > contentFrame.origin.x )
        originIsRight = YES;
    
#ifdef NOOO
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(context, 5);
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    CGPoint secondPoint = CGPointMake(firstPoint.x + 40, firstPoint.y);
    CGContextAddLineToPoint(context, secondPoint.x, secondPoint.y);
    //CGPoint controlPointOne = CGPointMake( self.bubbleOrigin.x, midpointBetweenBubbleAndOrigin);
    CGFloat yOffset = ( originIsAbove ? -20 : 20 );
    CGPoint controlPointOne = CGPointMake( secondPoint.x, secondPoint.y + yOffset);
    //CGContextAddCurveToPoint(context, controlPointOne.x, controlPointOne.y, controlPointTwo.x, controlPointTwo.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    CGContextAddQuadCurveToPoint(context, controlPointOne.x, controlPointOne.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    CGContextAddArc(context, self.bubbleOrigin.x, self.bubbleOrigin.y, 3, 0, 2 * M_PI, NO);
    //controlPointOne = CGPointMake( firstPoint.x - 5, firstPoint.y + 5);
    //controlPointTwo = CGPointMake(( firstPoint.x + self.bubbleOrigin.x ) / 2 - 10, ( firstPoint.y + self.bubbleOrigin.y ) / 2 - 10);
    //CGContextAddCurveToPoint(context, controlPointTwo.x - 10, controlPointTwo.y - 10, controlPointOne.x, controlPointOne.y, firstPoint.x, firstPoint.y);
    CGPoint controlPointTwo = CGPointMake( secondPoint.x + 20, secondPoint.y + yOffset);
    CGContextAddQuadCurveToPoint(context, controlPointTwo.x, controlPointTwo.y, firstPoint.x, firstPoint.y);
    CGContextSetFillColorWithColor(context, [UIColor speechBubbleColor].CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextFillPath(context);
    CGContextStrokePath(context);
#endif
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(context, 5);
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    CGPoint secondPoint = CGPointMake(firstPoint.x + 40, firstPoint.y);
    CGContextAddLineToPoint(context, secondPoint.x, secondPoint.y);
    //CGPoint controlPointOne = CGPointMake( self.bubbleOrigin.x, midpointBetweenBubbleAndOrigin);
    CGFloat yOffset = ( originIsAbove ? -20 : 20 );
    CGPoint controlPointOne = CGPointMake( secondPoint.x, secondPoint.y + yOffset);
    CGPoint controlPointTwo = CGPointMake( self.bubbleOrigin.x, self.bubbleOrigin.y + -(yOffset) );
    CGContextAddCurveToPoint(context, controlPointOne.x, controlPointOne.y, controlPointTwo.x, controlPointTwo.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    //CGContextAddQuadCurveToPoint(context, controlPointOne.x, controlPointOne.y, self.bubbleOrigin.x, self.bubbleOrigin.y);
    CGContextAddArc(context, self.bubbleOrigin.x, self.bubbleOrigin.y, 3, 0, 2 * M_PI, NO);
    //controlPointOne = CGPointMake( firstPoint.x - 5, firstPoint.y + 5);
    //controlPointTwo = CGPointMake(( firstPoint.x + self.bubbleOrigin.x ) / 2 - 10, ( firstPoint.y + self.bubbleOrigin.y ) / 2 - 10);
    CGFloat xOffset = ( originIsRight ? -20 : 20 );
    CGPoint controlPointThree = CGPointMake( self.bubbleOrigin.x + xOffset, self.bubbleOrigin.y + -(yOffset) );
    CGContextAddCurveToPoint(context, controlPointThree.x, controlPointThree.y, controlPointOne.x, controlPointOne.y, firstPoint.x, firstPoint.y);
    //CGContextAddQuadCurveToPoint(context, controlPointTwo.x, controlPointTwo.y, firstPoint.x, firstPoint.y);
    CGContextSetFillColorWithColor(context, [UIColor speechBubbleColor].CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
//#define DRAW_CONTROL_POINTS
#ifdef DRAW_CONTROL_POINTS
    CGContextAddArc(context, controlPointOne.x, controlPointOne.y, 3, 0, 2 * M_PI, NO);
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillPath(context);
    CGContextAddArc(context, controlPointTwo.x, controlPointTwo.y, 3, 0, 2 * M_PI, NO);
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextFillPath(context);
    CGContextAddArc(context, controlPointThree.x, controlPointThree.y, 3, 0, 2 * M_PI, NO);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextFillPath(context);
#endif
    
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

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if ( ! self.isCommandView && ! self.isMeterModeView )
//        return nil;
//    return [super hitTest:point withEvent:event];
//}

@end
