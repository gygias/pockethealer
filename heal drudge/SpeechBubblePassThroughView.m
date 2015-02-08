//
//  SpeechBubblePassThroughView.m
//  heal drudge
//
//  Created by david on 2/8/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpeechBubblePassThroughView.h"

#import "SpeechBubbleContentView.h"

@implementation SpeechBubblePassThroughView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    SpeechBubbleContentView *cv = ((SpeechBubbleContentView *)self.subviews.firstObject).subviews.firstObject;
    if ( CGRectContainsPoint(cv.frame, point) )
        return cv;
    return nil;
}

@end
