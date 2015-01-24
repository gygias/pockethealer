//
//  HolyFireSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "HolyFireSpell.h"

@implementation HolyFireSpell

- (id)initWithCaster:(Character *)caster
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
        self.castTime = 0;
        
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

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

@end
