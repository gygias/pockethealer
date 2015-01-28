//
//  Entity+AI.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity+AI.h"

@implementation Entity (AI)

- (AISpellPriority)currentSpellPriorities
{
    AISpellPriority priorities = FillerPriotity | CastOnCooldownPriority;
    double healthDelta = ( self.currentHealth.doubleValue - self.lastHealth.doubleValue ) / self.health.doubleValue;
    if ( healthDelta > 0.4 )
    {
        NSLog(@"%@: I've taken a lot of damage since my last update, I'm in fear of dying",self);
        priorities |= CastWhenInFearOfDyingPriority;
    }
    
    // if ( someWayOfKnowing.heroIncomingOrInProgress )
    //{
    //    NSLog(@"%@: Hero is imminent, I should use my buffs",self);
    //    priorities |= CastWhenDamageDoneIncreasedPriority;
    //}
    
    // if ( someWayOfKnowing.largeDamageIncoming )
    //{
    //    NSLog(@"%@: I'm about to get hit with something big, I should use my mitigation!",self);
    //    priorities |= CastBeforeLargeHitPriority;
    //}
    
    return priorities;
}

@end
