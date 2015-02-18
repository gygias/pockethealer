//
//  DancingRuneWeaponEffect.m
//  heal drudge
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DancingRuneWeaponEffect.h"

@implementation DancingRuneWeaponEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Dancing Rune Weapon";
        self.duration = ( 8 );
        self.image = [ImageFactory imageNamed:@"dancing_rune_weapon"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
        self.currentStacks = @1;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    BOOL modded = NO;
    if ( spell.caster.isEnemy && spell.target == self.owner )
    {
        EventModifier *mod = [EventModifier new];
        mod.parryIncreasePercentage = @0.2;
        [modifiers addObject:mod];
        modded = YES;
    }
    
    return modded;
}

@end
