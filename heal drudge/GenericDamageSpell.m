//
//  GenericDamageSpell.m
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GenericDamageSpell.h"

#import "Player.h"

@implementation GenericDamageSpell

- (id)initWithCaster:(Player *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Generic Damage";
        //self.image = [ImageFactory imageNamed:@"smite"];
        self.tooltip = @"Generic damage.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.castableRange = @30;
        self.castTime = @1.5;
        self.spellType = DetrimentalSpell;
        
        self.manaCost = @( 0.015 * caster.baseMana.floatValue );
        
        // hit
        self.damage = @( 0.92448 * caster.spellPower.floatValue );
        
        self.school = HolySchool;
    }
    return self;
}

@end
