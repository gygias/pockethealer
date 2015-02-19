//
//  PenanceSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PenanceSpell.h"

#import "EvangelismEffect.h"

@implementation PenanceSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Penance";
        self.image = [ImageFactory imageNamed:@"penance"];
        self.tooltip = @"Shoots a volley of holy light at somebody";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @9;
        self.spellType = BeneficialOrDeterimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @2;
        self.isChanneled = YES;
        self.channelTicks = @3;
        self.manaCost = @(0.0144 * caster.baseMana.doubleValue);//@(0.012 * caster.baseMana.floatValue);, that makes a player with 160000 static mana have 192000 "base mana"
        self.periodicDamage = @3777;
        self.periodicHeal = @10698;
        //self.absorb = @(( ( ( [caster.spellPower floatValue] * 5 ) + 2 ) * 1 ));
        
        self.school = HolySchool;
    }
    return self;
}

// one stack per cast, so this should be done on the 'start (of channel)' event
- (BOOL)addModifiers:(NSMutableArray *)modifiers
{
    if ( self.target.isEnemy )
    {
        EvangelismEffect *currentEvangelism = [PriestSpell _evangelismForEntity:self.caster];
        if ( ! currentEvangelism )
        {
            currentEvangelism = [EvangelismEffect new];
            [self.caster addStatusEffect:currentEvangelism source:self.caster];
        }
        else
            [currentEvangelism addStack];
    }
    
    return YES;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenAnyoneNeedsHealing | CastWhenAnyoneNeedsUrgentHealing;
}

@end
