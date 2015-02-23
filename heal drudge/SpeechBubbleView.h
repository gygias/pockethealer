//
//  SpeechBubbleView.h
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpeechBubbleView : UIView

@property BOOL isCommandView;
@property BOOL isMeterModeView;
@property CGPoint bubbleOrigin;
@property UIView *referenceView;

@end
