//
//  SpellPriv.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Spell.h"

@interface Spell (Priv)

- (void)_applyDamage:(Entity *)entity;
- (void)_applyHealing:(Entity *)entity;
- (void)_applyAbsorbs:(Entity *)entity;
- (void)_applyStatusEffects:(Entity *)entity;

- (Effect *)_existingEffectWithClass:(Class)aClass;

@end

