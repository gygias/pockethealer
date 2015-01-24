//
//  Spell.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "Spell.h"
#import "SpellPriv.h"

@implementation Spell

- (id)initWithCaster:(Character *)caster
{
    if ( self = [super init] )
    {
        self.caster = caster;
    }
    return self;
}

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString **)message
{
    return YES;
}

- (void)hitWithSource:(Entity *)source target:(Entity *)target
{
}

+ (NSArray *)castableSpellNamesForCharacter:(Character *)character
{
    NSMutableArray *castableSpells = [NSMutableArray new];
    for ( NSString *spellName in [self _spellNames] )
    {
        Class spellClass = NSClassFromString(spellName);
        Spell *spell = [[spellClass alloc] initWithCaster:character];
        if ( spell )
        {
            if ( [[spell hdClasses] containsObject:character.hdClass] )
            {
                NSLog(@"%@s can cast %@",character.hdClass,spell);
                [castableSpells addObject:spell];
            }
        }
        else
            NSLog(@"failed to initialize %@",spellName);
    }
    
    return castableSpells;
}

+ (NSArray *)_spellNames
{
    return @[
             @"PowerWordShieldSpell",
             @"HolyFireSpell",
             @"SmiteSpell",
             @"HealSpell",
             @"FlashHealSpell",
             @"ArchangelSpell",
             @"DivineStarSpell",
             
             @"HealingTideTotemSpell"
             ];
}

@end
