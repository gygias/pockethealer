//
//  TouchDemoView.h
//  pockethealer
//
//  Created by david on 3/12/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#define MOVE_DURATION 1.0

@interface TouchDemoView : UIView

- (void)doTouch;
- (void)moveTo:(CGPoint)point;

@end
