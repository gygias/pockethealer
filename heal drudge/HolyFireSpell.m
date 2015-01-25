//
//  HolyFireSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "HolyFireSpell.h"

#import "EvangelismEffect.h"

@implementation HolyFireSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Fire";
        self.image = [ImageFactory imageNamed:@"holy_fire"];
        self.tooltip = @"Consumes the enemy in Holy flames.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @10;
        self.castableRange = @30;
        self.castTime = @0;
        self.spellType = DetrimentalSpell;
        
        self.manaCost = @( 0.01 * caster.baseMana.floatValue );
        
        // hit
        self.damage = @( 1.3761 * caster.spellPower.floatValue );
        self.damageType = HolyDamage;
        
        // periodic
        self.isPeriodic = YES;
        self.period = 1;
        self.periodicDuration = 9;
        self.periodicDamage = @( 0.03315 * caster.spellPower.floatValue );
        self.periodicDamageType = HolyDamage;
    }
    return self;
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    EvangelismEffect *currentEvangelism = [self _evangelismForEntity:source];
    if ( ! currentEvangelism )
    {
        currentEvangelism = [EvangelismEffect new];
        [source addStatusEffect:currentEvangelism source:source];
    }
    else
        [currentEvangelism addStack];
}

- (EvangelismEffect *)_evangelismForEntity:(Entity *)entity
{
    for ( Effect *effect in entity.statusEffects )
    {
        if ( [effect isKindOfClass:[EvangelismEffect class]] )
        {
            return (EvangelismEffect *)effect;
        }
    }
    return nil;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

@end
