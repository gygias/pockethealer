//
//  TankExplanationView.m
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpeechBubbleViewController.h"

#import "SpeechBubbleView.h"

@implementation SpeechBubbleViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    //[super viewDidLoad];
}

- (void)setBubbleOrigin:(CGPoint)bubbleOrigin
{
    ((SpeechBubbleView *)self.view.subviews.firstObject).bubbleOrigin = bubbleOrigin;
    
    // XXX
    self.speechBubbleContentView.dismissHandler = ^(SpeechBubbleContentView *view){
        if ( self.dismissHandler )
            self.dismissHandler(self);
    };
}

- (CGPoint)bubbleOrigin
{
    return ((SpeechBubbleView *)self.view.subviews.firstObject).bubbleOrigin;
}

@end
