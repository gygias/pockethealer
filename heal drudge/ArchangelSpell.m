//
//  ArchangelSpell.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ArchangelSpell.h"

#import "ArchangelEffect.h"
#import "EvangelismEffect.h"

@implementation ArchangelSpell

- (id)initWithCaster:(Entity *)caster
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

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString **)message
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

- (void)hitWithSource:(Entity *)source target:(Entity *)target
{
    EvangelismEffect *evangelism = [self _evangelismForEntity:source];
    ArchangelEffect *effect = [ArchangelEffect new];
    [effect addStacks:evangelism.currentStacks.unsignedIntegerValue - 1];
    
    [source addStatusEffect:effect source:source];
    [source removeStatusEffect:evangelism];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
