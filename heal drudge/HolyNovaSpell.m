//
//  HolyNovaSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "HolyNovaSpell.h"

@implementation HolyNovaSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Nova";
        self.image = [ImageFactory imageNamed:@"holy_nova"];
        self.tooltip = @"Causes an explosion of holy light around the caster.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialOrDeterimentalSpell;
        self.castableRange = @0;
        
        self.castTime = @0;
        self.manaCost = @(0.016 * caster.baseMana.floatValue); // 2560
        self.damage = @466;
        self.healing = @466;
        self.hitRange = @12;
        self.maxHitTargets = @5;
        //self.absorb = @(( ( ( [caster.spellPower floatValue] * 5 ) + 2 ) * 1 ));
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
