//
//  PlayerAndTargetView.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PlayerAndTargetView.h"

#import "RaidFrameView.h"
#import "Entity.h"

@implementation PlayerAndTargetView

#define PLAYER_TARGET_OFFSET 10
- (CGSize)intrinsicContentSize
{
    return CGSizeMake(3 * PLAYER_TARGET_OFFSET + 3 * [RaidFrameView desiredSize].width, [RaidFrameView desiredSize].height);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    _lastDrawnRect = rect;
    
    // player
    if ( self.player )
    {
        CGRect playerRect = [self _playerRectWithRect:rect];
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:playerRect];
        aFrame.entity = self.player;
        aFrame.player = self.player;
        [aFrame drawRect:playerRect];
    }
    
    // target
    if ( self.target )
    {
        CGRect targetRect = [self _targetRectWithRect:rect];
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:targetRect];
        aFrame.entity = self.target;
        aFrame.player = self.player;
        [aFrame drawRect:targetRect];
    }
    
    // target
    if ( self.target.target )
    {
        CGRect targetRect = [self _targetOfTargetRectWithRect:rect];
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:targetRect];
        //aFrame.scale = 0.5;
        aFrame.entity = self.target.target;
        aFrame.player = self.player;
        [aFrame drawRect:targetRect];
    }
}

- (CGRect)_playerRectWithRect:(CGRect)rect
{
    CGSize frameSize = [RaidFrameView desiredSize];
    return CGRectMake( rect.origin.x, rect.origin.y, frameSize.width, frameSize.height );
}

- (CGRect)_targetRectWithRect:(CGRect)rect
{
    CGSize frameSize = [RaidFrameView desiredSize];
    return CGRectMake( rect.origin.x + frameSize.width + PLAYER_TARGET_OFFSET, rect.origin.y, frameSize.width, frameSize.height );
}

- (CGRect)_targetOfTargetRectWithRect:(CGRect)rect
{
    CGSize frameSize = [RaidFrameView desiredSize];
    return CGRectMake( rect.origin.x + 2 * frameSize.width + 2 * PLAYER_TARGET_OFFSET, rect.origin.y, frameSize.width, frameSize.height );
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    Entity *theTouchedEntity = nil;
    if ( CGRectContainsPoint([self _playerRectWithRect:_lastDrawnRect],[theTouch locationInView:self]) )
        theTouchedEntity = self.player;
    else if ( CGRectContainsPoint([self _targetRectWithRect:_lastDrawnRect], [theTouch locationInView:self]) )
        theTouchedEntity = self.target;
    else if ( CGRectContainsPoint([self _targetOfTargetRectWithRect:_lastDrawnRect], [theTouch locationInView:self]) )
        theTouchedEntity = self.target.target;
    if ( theTouchedEntity )
    {
        //PHLogV(@"you touched %@",theTouchedEntity);
        
        if ( self.entityTouchedHandler )
            self.entityTouchedHandler(theTouchedEntity);
    }
}

@end
