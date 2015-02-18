//
//  GenericPhysicalAttackSpell.m
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "GenericPhysicalAttackSpell.h"

@implementation GenericPhysicalAttackSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Attack";
        //self.image = [ImageFactory imageNamed:@"smite"];
        self.tooltip = @"Generic physical attack.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @5;
        self.castableRange = @30;
        self.castTime = @0;
        self.spellType = DetrimentalSpell;
        self.hitSoundName = @"physical_hit";
        //self.castSoundName = @"cast_shadow";
        
        self.manaCost = @( caster.power.doubleValue * .4 );
        
        // hit
        if ( caster.hdClass.isMeleeDPS || caster.hdClass.isTank )
            self.damage = @( 0.92448 * caster.attackPower.floatValue );
        
        self.school = PhysicalSchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return [HDClass allMeleeClassSpecs];
}

- (AISpellPriority)aiSpellPriority
{
    return FillerPriority;
}

@end
