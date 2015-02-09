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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( self.raid.players.count == 0 )
    {
        PHLogV(@"raid has no players or is nil!");
        return;
    }
    
    NSUInteger idx = 0;
    NSUInteger partySize = 5;
    CGSize frameSize = [RaidFrameView desiredSize];
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
        if ( idx == self.selectedFrame )
            aFrame.selected = YES;
        [aFrame drawRect:thisRect];
    }
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

- (CGPoint)originForEntity:(Entity *)e
{
    NSUInteger idx = [self.raid.players indexOfObject:e];
    NSUInteger partySize = 5;
    CGSize frameSize = [RaidFrameView desiredSize];
    NSUInteger idxParty = idx / partySize;
    NSUInteger partyPosition = idx % partySize;
    return CGPointMake(self.frame.origin.x + idxParty * frameSize.width + frameSize.width / 2, self.frame.origin.y + partyPosition * frameSize.height + frameSize.height / 2);
}

@end
