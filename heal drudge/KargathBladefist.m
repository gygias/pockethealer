//
//  KargathBladefist.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "KargathBladefist.h"

#import "Raid.h"

@implementation KargathBladefist

- (id)initWithRaid:(Raid *)raid
{
    if ( self = [super initWithRaid:raid] )
    {
        self.stamina = @(500000 / 60 * ( ( raid.players.count < 5 ? 5 : raid.players.count ) / 5 ));
        self.aggroSoundName = @"kargath_aggro";
        self.hitSoundName = @"kargath_hit";
        self.deathSoundName = @"kargath_death";
    }    
    return self;
}

- (void)beginEncounter:(Encounter *)encounter
{
    [super beginEncounter:encounter];
}

- (NSArray *)abilityNames
{
    return @[@"Attack",@"BladeDance",@"Impale",@"BerserkerRush"];
}

@end
