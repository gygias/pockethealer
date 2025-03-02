//
//  PassThroughView.m
//  heal drudge
//
//  Created by david on 2/19/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PassThroughView.h"

@implementation PassThroughView

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

@end
