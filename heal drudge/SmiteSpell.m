//
//  SmiteSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SmiteSpell.h"

#import "Entity.h"
#import "EvangelismEffect.h"

@implementation SmiteSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Smite";
        self.image = [ImageFactory imageNamed:@"smite"];
        self.tooltip = @"Smite an enemy.";
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

- (void)handleHitWithModifier:(EventModifier *)modifier
{    
    EvangelismEffect *currentEvangelism = [self _evangelismForEntity:self.caster];
    if ( ! currentEvangelism )
    {
        currentEvangelism = [EvangelismEffect new];
        [self.caster addStatusEffect:currentEvangelism source:self.caster];
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
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

@end
