//
//  SpeechBubbleContentView.h
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@interface SpeechBubbleContentView : UIView

typedef void (^SpeechBubbleContentViewDismissedHandler)(SpeechBubbleContentView *);
@property (copy) SpeechBubbleContentViewDismissedHandler dismissHandler;

@end
