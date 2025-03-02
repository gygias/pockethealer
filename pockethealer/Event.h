//
//  Event.h
//  pockethealer
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

@class Spell;

@interface Event : NSObject

@property Spell *spell;
@property NSNumber *netDamage;
@property NSNumber *netHealing;
@property NSNumber *netAffected;
@property NSNumber *netBlocked;
@property NSNumber *netParried;
@property NSNumber *netDodged;
@property NSNumber *netArmorReduction;
@property NSNumber *netAbsorbed;
@property NSNumber *netHealedOnDamage;

@end
