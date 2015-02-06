//
//  Ability.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Spell.h"

typedef NS_ENUM(NSInteger, AbilityLevel) {
    NormalAbility       = 0,
    NotableAbility      = 1,
    DangerousAbility    = 2,
    CatastrophicAbility = 3
};

@interface Ability : Spell

@property NSDate *nextFireDate; // dispatch-fy this?
@property BOOL canTargetTanks;
@property AbilityLevel abilityLevel;

@end
