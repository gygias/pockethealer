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
    AISpellPriority priorities = FillerPriotity;
    double healthPercentage = self.currentHealth.doubleValue / self.health.doubleValue;
    double healthDelta = ( self.currentHealth.doubleValue - self.lastHealth.doubleValue ) / self.health.doubleValue;
    if ( healthDelta > 0.33 )
    {
        NSLog(@"%@: I've taken a lot of damage since my last update, I'm in fear of dying",self);
        priorities |= CastWhenInFearOfDyingPriority; // TODO "nervous, chance to mistakenly blow large cd?"
    }
    if ( healthPercentage <= 0.33 )
    {
        NSLog(@"%@: I'm at %0.0f%% health and am in fear of dying",self,healthPercentage*100);
        priorities |= CastWhenInFearOfDyingPriority;
    }
    if ( healthPercentage < 1.0 )
    {
        NSLog(@"%@: I'm at %0.0f%% health so I need healing",self,healthPercentage*100);
        priorities |= CastWhenTankNeedsHealingPriority;
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
