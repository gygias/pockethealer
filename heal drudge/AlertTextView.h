//
//  AlertTextView.h
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class AlertText;

@interface AlertTextView : UIView

@property (readonly) NSArray *alertTexts;

- (void)addAlertText:(AlertText *)alertText;

@end
