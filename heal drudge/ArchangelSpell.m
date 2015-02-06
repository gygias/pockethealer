//
//  ArchangelSpell.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ArchangelSpell.h"

#import "ArchangelEffect.h"
#import "EvangelismEffect.h"
#import "EmpoweredArchangelEffect.h"

@implementation ArchangelSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Archangel";
        self.image = [ImageFactory imageNamed:@"archangel"];
        self.tooltip = @"Makes you wig out and be really sweet.";
        self.triggersGCD = YES;
        self.cooldown = @30;
        self.spellType = BeneficialSpell;
        self.castableRange = @0;
        self.hitRange = @0;
        
        self.castTime = @0.0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
    }
    return self;
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

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{
    EvangelismEffect *evangelism = [self _evangelismForEntity:source];
    
    if ( ! evangelism )
    {
        if ( message )
            *message = @"Must have Evangelism stacks to cast Archangel";
        return NO;
    }
    return YES;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{    
    EvangelismEffect *evangelism = [self _evangelismForEntity:self.caster];
    
    ArchangelEffect *aa = [ArchangelEffect new];
    [aa addStacks:evangelism.currentStacks.unsignedIntegerValue - 1];
    [self.caster addStatusEffect:aa source:self.caster];
    
    EmpoweredArchangelEffect *eaa = [EmpoweredArchangelEffect new];
    [self.caster addStatusEffect:eaa source:self.caster];
    
    [self.caster consumeStatusEffect:evangelism absolute:YES];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
