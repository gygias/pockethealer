//
//  PlayerAndTargetView.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PlayerAndTargetView.h"

#import "RaidFramesView.h"
#import "RaidFrameView.h"
#import "Entity.h"

@implementation PlayerAndTargetView

#define PLAYER_TARGET_OFFSET 10
- (CGSize)intrinsicContentSize
{
    return CGSizeMake(3 * PLAYER_TARGET_OFFSET + 3 * [RaidFrameView desiredSize].width, [RaidFrameView desiredSize].height);
}

- (CGPoint)playerOrigin
{
    CGRect playerRect = [self _playerRectWithRect:_lastDrawnRect];
    CGPoint origin = playerRect.origin;
    origin.x += playerRect.size.width / 2;
    origin.y += playerRect.size.height / 2;
    return origin;    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    _lastDrawnRect = rect;
    
    UIImage *imageCache = nil;
    
    // player
    if ( self.player )
    {
        CGRect playerRect = [self _playerRectWithRect:rect];
        
        if ( ( imageCache = self.raidFramesView.playerFrame.imageCache ) )
            [imageCache drawInRect:playerRect];
        else
            [self.raidFramesView.playerFrame drawRect:playerRect];
    }
    
    // target
    if ( self.target )
    {
        CGRect targetRect = [self _targetRectWithRect:rect];
        
        if ( ( imageCache = self.raidFramesView.playerTargetFrame.imageCache ) )
            [imageCache drawInRect:targetRect];
        else if ( self.raidFramesView.playerTargetFrame )
            [self.raidFramesView.playerTargetFrame drawRect:targetRect];
        else if ( self.lastTargetFrame.entity == self.target )
            [self.lastTargetFrame drawRect:targetRect];
        else
        {
            self.lastTargetFrame = [RaidFrameView new];
            self.lastTargetFrame.entity = self.target;
            self.lastTargetFrame.player = self.player;
            [self.lastTargetFrame drawRect:targetRect];
        }            
    }
    
    // target
    if ( self.target.target )
    {
        CGRect targetTargetRect = [self _targetOfTargetRectWithRect:rect];
        
        if ( ( imageCache = self.raidFramesView.playerTargetTargetFrame.imageCache ) )
            [imageCache drawInRect:targetTargetRect];
        else if ( self.raidFramesView.playerTargetTargetFrame )
            [self.raidFramesView.playerTargetTargetFrame drawRect:targetTargetRect];
        else if ( self.lastTargetTargetFrame.entity == self.target.target )
            [self.lastTargetTargetFrame drawRect:targetTargetRect];
        else
        {
            self.lastTargetTargetFrame = [RaidFrameView new];
            self.lastTargetTargetFrame.entity = self.target.target;
            self.lastTargetTargetFrame.player = self.player;
            [self.lastTargetTargetFrame drawRect:targetTargetRect];
        }
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

- (CGPoint)centerOfPlayer
{
    return CGRectGetMid([self _playerRectWithRect:_lastDrawnRect]);
}

- (CGPoint)centerOfTarget
{
    return CGRectGetMid([self _targetRectWithRect:_lastDrawnRect]);
}

- (CGPoint)centerOfTargetTarget
{
    return CGRectGetMid([self _targetOfTargetRectWithRect:_lastDrawnRect]);
}

@end
