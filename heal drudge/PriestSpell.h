//
//  PriestSpell.h
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Spell.h"

@class DivineAegisEffect, EvangelismEffect, ArchangelEffect;

@interface PriestSpell : Spell

+ (DivineAegisEffect *)_divineAegisForEntity:(Entity *)entity;
+ (EvangelismEffect *)_evangelismForEntity:(Entity *)entity;
+ (ArchangelEffect *)_archangelForEntity:(Entity *)entity;

@end
