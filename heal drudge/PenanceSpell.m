//
//  PenanceSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PenanceSpell.h"

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
        
        self.castTime = @0;
        self.isChanneled = YES;
        self.channelTime = @2;
        self.manaCost = @(0.0144 * caster.baseMana.doubleValue);//@(0.012 * caster.baseMana.floatValue);, that makes a player with 160000 static mana have 192000 "base mana"
        self.damage = @3777;
        self.healing = @10698;
        //self.absorb = @(( ( ( [caster.spellPower floatValue] * 5 ) + 2 ) * 1 ));
    }
    return self;
}

- (void)hitWithSource:(Entity *)source target:(Entity *)target
{
    [super hitWithSource:source target:target];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
