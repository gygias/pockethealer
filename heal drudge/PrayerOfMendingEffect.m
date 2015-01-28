//
//  PrayerOfMendingEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PrayerOfMendingEffect.h"

#import "ImageFactory.h"

#import "Entity.h"
#import "Encounter.h"
#import "NSCollections+Random.h"

@implementation PrayerOfMendingEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Prayer of Mending";
        self.duration = 30;
        self.currentStacks = @5;
        self.image = [ImageFactory imageNamed:@"prayer_of_mending"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
        self.healingOnDamageIsOneShot = YES;
    }
    
    return self;
}

- (void)handleConsumptionWithOwner:(Entity *)owner
{
    Entity *someOtherPlayer = nil;
    do
    {
        someOtherPlayer = [self _randomLivingPlayerFrom:owner.encounter.raid.players];
    } while ( ! someOtherPlayer.isDead && someOtherPlayer == owner );
    
    [someOtherPlayer addStatusEffect:self source:self.source];
    [owner consumeStatusEffect:self absolute:YES];
}

// TODO buggy and copied from Enemy, centralize
- (Entity *)_randomLivingPlayerFrom:(NSArray *)players
{
    __block Entity *randomLivingPlayer = nil;
    
    // TODO this is racey
    NSMutableArray *livingPlayers = [NSMutableArray new];
    [players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
        //NSLog(@"%@ is %@",obj,obj.isDead?@"dead":@"alive");
        if ( ! obj.isDead )
            [livingPlayers addObject:obj];
    }];
    
    if ( [livingPlayers count] == 0 )
        return randomLivingPlayer;
    
    return [livingPlayers objectAtIndex:arc4random() % [livingPlayers count]];
}

@end
