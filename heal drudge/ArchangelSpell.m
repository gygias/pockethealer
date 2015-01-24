//
//  ArchangelSpell.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ArchangelSpell.h"

@implementation ArchangelSpell

- (id)initWithCaster:(Character *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Archangel";
        self.image = [ImageFactory imageNamed:@"archangel"];
        self.tooltip = @"Makes you wig out and be really sweet.";
        self.triggersGCD = YES;
        self.cooldown = @0;
        self.isBeneficial = YES;
        self.castableRange = @0;
        self.hitRange = @0;
        
        self.castTime = 0.0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
