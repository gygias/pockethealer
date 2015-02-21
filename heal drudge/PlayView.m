//
//  PlayView.m
//  heal drudge
//
//  Created by david on 2/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithRect:self.frame] fill];
    
    if ( self.auxiliaryDrawHandler )
        self.auxiliaryDrawHandler();
}

@end
