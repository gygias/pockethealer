//
//  PowerWordShieldSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PowerWordShieldSpell.h"
#import "WeakenedSoulEffect.h"
#import "Entity.h"

@implementation PowerWordShieldSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Power Word: Shield";
        self.image = [ImageFactory imageNamed:@"power_word_shield"];
        self.tooltip = @"Shields a friendly target";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @6;
        self.isBeneficial = YES;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = 0;
        self.manaCost = @(0.024 * caster.baseMana.floatValue);
        self.damage = @0;
        self.healing = @0;
        self.absorb = @(( ( ( [caster.spellPower floatValue] * 5 ) + 2 ) * 1 ));
    }
    return self;
}

- (void)hitWithSource:(Entity *)source target:(Entity *)target
{
    [super hitWithSource:source target:target];
    
    // borrowed time
    
    // weakened soul
    WeakenedSoulEffect *weakenedSoul = [WeakenedSoulEffect new];
    weakenedSoul.source = source;
    
    [target addStatusEffect:weakenedSoul];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

@end
