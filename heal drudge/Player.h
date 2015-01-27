//
//  Player.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@class Spell;

#define HD_NAME_MIN 3
#define HD_NAME_MAX 12

@interface Player : Entity

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter;

@end
