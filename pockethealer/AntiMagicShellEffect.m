//
//  AntiMagicShellEffect.m
//  pockethealer
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AntiMagicShellEffect.h"

@implementation AntiMagicShellEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Anti-Magic Shell";
        self.duration = ( 5 );
        self.image = [ImageFactory imageNamed:@"anti-magic_shell"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
        self.currentStacks = @1;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    BOOL modded = NO;
    if ( spell.caster.isEnemy && spell.target == self.owner && spell.school == MagicSchool )
    {
        EventModifier *mod = [EventModifier new];
        mod.damageTakenDecreasePercentage = @0.75;
        [modifiers addObject:mod];
        modded = YES;
    }
    
    return modded;
}

@end
