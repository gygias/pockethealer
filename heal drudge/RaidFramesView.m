//
//  RaidFramesView.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "RaidFramesView.h"
#import "RaidFrameView.h"
#import "Entity.h"
#import "Encounter.h"

@implementation RaidFramesView

@synthesize raid = _raid;

static CGSize sMyDesiredContentSize = {0,0};
- (CGSize)intrinsicContentSize
{
    NSUInteger nRows = self.raid.players.count >= 5 ? 5 : self.raid.players.count;
    NSUInteger nColumns = self.raid.players.count / 5 + 1;
    sMyDesiredContentSize = CGSizeMake([RaidFrameView desiredSize].width * ( nColumns ), [RaidFrameView desiredSize].height * ( nRows ));
    return sMyDesiredContentSize;
}

- (void)setRaid:(Raid *)raid
{
    [self invalidateIntrinsicContentSize];
    _raid = raid;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( self.raid.players.count == 0 )
    {
        PHLogV(@"raid has no players or is nil!");
        return;
    }
    
    //if ( rect.size.width != sMyDesiredContentSize.width || rect.size.height != sMyDesiredContentSize.height )
    //    PHLogV(@"(%0.2f,%0.2f) [%0.2f,%0.2f] vs [%0.2f,%0.2f]",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height,sMyDesiredContentSize.width,sMyDesiredContentSize.height);
    
    if ( ! CGRectEqualToRect(_lastRect, rect) )
    {
        _lastRect = rect;
        _refreshCachedValues = YES;
    }
    
    if ( _refreshCachedValues || ! _raidFrames )
        [self _initRaidFrames];
    
    self.playerTargetTargetFrame = nil;
    self.playerTargetFrame = nil;
    [_raidFrames enumerateObjectsUsingBlock:^(RaidFrameView *aFrame, NSUInteger idx, BOOL *stop) {
        [aFrame drawRect:aFrame.frame];
        
        if ( self.encounter.player.target == aFrame.entity )
            self.playerTargetFrame = aFrame;
        if ( self.encounter.player.target.target == aFrame.entity )
            self.playerTargetTargetFrame = aFrame;
    }];
//#define DEBUG_ORIGIN
#ifdef DEBUG_ORIGIN
    [_raidFrames enumerateObjectsUsingBlock:^(RaidFrameView *aFrame, NSUInteger idx, BOOL *stop) {
        CGPoint thePoint = [self originForEntity:aFrame.entity];
        [aFrame.entity.name drawAtPoint:thePoint withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx,5);
        CGContextSetFillColorWithColor(ctx, [UIColor purpleColor].CGColor);
        CGContextAddArc(ctx,thePoint.x,thePoint.y,2,0.0,M_PI*2,YES);
        CGContextFillPath(ctx);
    }];
#endif
    
    _refreshCachedValues = NO;
}

- (void)_initRaidFrames
{    
    NSUInteger idx = 0;
    NSUInteger partySize = 5;
    CGSize frameSize = [RaidFrameView desiredSize];
    NSMutableArray *mutableFrames = [NSMutableArray new];
    for ( ; idx < self.raid.players.count; idx++ )
    {
        Entity *thisPlayer = self.raid.players[idx];
        NSUInteger idxParty = idx / partySize;
        NSUInteger partyPosition = idx % partySize;
        //PHLogV(@"%@: party: %lu, pos: %lu",thisPlayer,idxParty,partyPosition);
        CGRect thisRect = CGRectMake( idxParty * frameSize.width, partyPosition * frameSize.height, frameSize.width, frameSize.height );
        RaidFrameView *aFrame = [[RaidFrameView alloc] initWithFrame:thisRect];
        
        aFrame.encounter = self.encounter;
        BOOL (^entityIsTargetedBlock)(Entity *);
        entityIsTargetedBlock = ^(Entity *entity) {
            return [self.encounter entityIsTargetedByEntity:entity];
        };
        
        aFrame.entity = thisPlayer;
        aFrame.player = self.player;
        [mutableFrames addObject:aFrame];
        
        if ( thisPlayer.isPlayingPlayer )
            self.playerFrame = aFrame;
    }
    
    _raidFrames = mutableFrames;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //PHLogV(@"touches ended: %@",event);
    //PHLogV(@"for me: %@",[event touchesForView:self]);
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    // determine which player
    NSUInteger  party = [theTouch locationInView:self].x / [RaidFrameView desiredSize].width,
                pos = [theTouch locationInView:self].y / [RaidFrameView desiredSize].height;
    //PHLogV(@"party: %lu pos: %lu",party,pos);
    self.selectedFrame = ( party * 5 ) + pos;
    
    if ( self.targetedPlayerBlock )
    {
        if ( self.selectedFrame < self.raid.players.count )
            self.targetedPlayerBlock( self.raid.players[self.selectedFrame] );
    }
    
    [self setNeedsDisplay];
}

- (CGPoint)absoluteOriginForEntity:(Entity *)e
{
    return [self convertPoint:[self originForEntity:e] toView:nil];
}

- (CGPoint)originForEntity:(Entity *)e
{
    __block CGPoint thePoint = {0};
    [_raidFrames enumerateObjectsUsingBlock:^(RaidFrameView *aFrame, NSUInteger idx, BOOL *stop) {
        if ( aFrame.entity == e )
        {
            thePoint = CGPointMake(aFrame.frame.origin.x + aFrame.frame.size.width / 2,
                                   aFrame.frame.origin.y + aFrame.frame.size.height / 2);
            *stop = YES;
        }
    }];
    return thePoint;
}

@end
