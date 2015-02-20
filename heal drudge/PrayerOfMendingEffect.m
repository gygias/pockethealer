//
//  PrayerOfMendingEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PrayerOfMendingEffect.h"

#import "ImageFactory.h"

#import "Entity.h"
#import "Encounter.h"

@implementation PrayerOfMendingEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Prayer of Mending";
        self.duration = 30;
        self.maxStacks = @5;
        self.currentStacks = @5;
        self.image = [ImageFactory imageNamed:@"prayer_of_mending"];
        self.hitSoundName = @"prayer_of_mending_hit";
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
        self.healingOnDamageIsOneShot = YES;
    }
    
    return self;
}

- (BOOL)validateOwner:(Entity *)owner
{
    if ( ! [super validateOwner:owner] )
        return NO;
    
    [owner.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[PrayerOfMendingEffect class]] )
            [owner consumeStatusEffect:obj absolute:YES];
    }];
    
    return YES;
}

- (void)handleConsumptionWithOwner:(Entity *)owner
{
    Entity *someOtherPlayer = [self _randomLivingPlayerFrom:owner.encounter.raid.players excludingPlayer:owner];
    if ( someOtherPlayer )
        [someOtherPlayer addStatusEffect:self source:self.source];
    [owner consumeStatusEffect:self absolute:YES];
}

// TODO buggy and copied from Enemy, centralize
- (Entity *)_randomLivingPlayerFrom:(NSArray *)players excludingPlayer:(Entity *)excludingPlayer
{
    __block Entity *randomLivingPlayer = nil;
    
    // TODO this is racey
    NSMutableArray *livingPlayers = [NSMutableArray new];
    [players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
        //PHLogV(@"%@ is %@",obj,obj.isDead?@"dead":@"alive");
        if ( ! obj.isDead && obj != excludingPlayer )
            [livingPlayers addObject:obj];
    }];
    
    if ( [livingPlayers count] == 0 )
        return randomLivingPlayer;
    
    return [livingPlayers objectAtIndex:arc4random() % [livingPlayers count]];
}

@end
