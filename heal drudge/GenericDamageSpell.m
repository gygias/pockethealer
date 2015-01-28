//
//  GenericDamageSpell.m
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GenericDamageSpell.h"

#import "Entity.h"

@implementation GenericDamageSpell

- (id)initWithCaster:(Entity *)caster
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
        if ( caster.hdClass.isCasterDPS )
            self.damage = @( 0.92448 * caster.spellPower.floatValue );
        else if ( caster.hdClass.isMeleeDPS || caster.hdClass.isTank )
            self.damage = @( 0.92448 * caster.attackPower.floatValue );
        
        self.school = HolySchool;
    }
    return self;
}

@end
