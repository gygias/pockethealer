//
//  SpellDragView.m
//  pockethealer
//
//  Created by david on 2/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpellDragView.h"

@implementation SpellDragView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if ( self.spellDragDrawHandler )
        self.spellDragDrawHandler(rect);
    if ( self.touchDemoDrawHandler )
        self.touchDemoDrawHandler(rect);
}

@end
