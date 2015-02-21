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
    __unsafe_unretained typeof(self) weakSelf = self;
    self.speechBubbleContentView.dismissHandler = ^(SpeechBubbleContentView *view){
        if ( weakSelf.dismissHandler )
            weakSelf.dismissHandler(weakSelf);
    };
}

- (void)setReferenceView:(UIView *)referenceView
{
    ((SpeechBubbleView *)self.view.subviews.firstObject).referenceView = referenceView;
    
}

- (CGPoint)bubbleOrigin
{
    return ((SpeechBubbleView *)self.view.subviews.firstObject).bubbleOrigin;
}

@end
