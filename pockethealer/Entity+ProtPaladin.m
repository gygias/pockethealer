//
//  Entity+ProtPaladin.m
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity+ProtPaladin.h"

#import "Entity+AI.h"
#import "Event.h"
#import "Encounter.h"

#import "AvengersShieldSpell.h"

@implementation Entity (ProtPaladin)

- (void)handleProtPallyIncomingDamageEvent:(Event *)damageEvent
{
    if ( damageEvent.spell.school == PhysicalSchool )
    {
        AvengersShieldSpell *asSpell = (AvengersShieldSpell *)[self spellWithClass:[AvengersShieldSpell class]];
        if ( asSpell && asSpell.isOnCooldown )
        {
            // roll for CD reset
            // Grand Crusader: "When you avoid a melee attack you have a 30% chance of refreshing the cooldown on your next Avenger's Shield and causing it to generate 1 Holy Power."
            // TODO i think this is not totally correct, would proc too much, going with block for now
            if ( damageEvent.netBlocked )
            {
                asSpell.nextCooldownDate = nil;
                [self emphasizeSpell:asSpell duration:5]; // TODO how long does the proc glow for?
            }
        }
    }
}

@end
