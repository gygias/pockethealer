//
//  PlayerAndTargetView.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PlayerAndTargetView.h"

#import "RaidFrameView.h"
#import "Entity.h"

@implementation PlayerAndTargetView

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGSize frameSize = [RaidFrameView desiredSize];
    
    // player
    if ( self.player )
    {
        CGRect playerRect = CGRectMake( rect.origin.x, rect.origin.y, frameSize.width, frameSize.height );
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:playerRect];
        aFrame.entity = self.player;
        aFrame.player = self.player;
        [aFrame drawRect:playerRect];
    }
    
    // target
    if ( self.target )
    {
        CGRect targetRect = CGRectMake( rect.origin.x + 2 * frameSize.width, rect.origin.y, frameSize.width, frameSize.height );
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:targetRect];
        aFrame.entity = self.target;
        aFrame.player = self.player;
        [aFrame drawRect:targetRect];
    }
}

@end
