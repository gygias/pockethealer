//
//  EmpoweredArchangelEffect.m
//  heal drudge
//
//  Created by david on 2/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "EmpoweredArchangelEffect.h"

#import "PrayerOfHealingSpell.h"
#import "FlashHealSpell.h"

@implementation EmpoweredArchangelEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Empowered Archangel";
        self.duration = 30;
        self.effectType = BeneficialEffect;
        self.image = [ImageFactory imageNamed:@"archangel"];
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.caster != self.source )
        return NO;
    
    if ( ! [spell isKindOfClass:[PrayerOfHealingSpell class]]
        && ! [spell isKindOfClass:[FlashHealSpell class]] )
        return NO;
    
    // TODO does 'beneficial' imply healing is defined? does it matter?
    EventModifier *mod = [EventModifier new];
    PHLog(spell,@"%@'s %@ should crit due to EAA!",spell.caster,spell);
    mod.crit = YES;
    mod.source = self;
    [mod addBlock:^{
        [spell.caster consumeStatusEffect:self absolute:YES];
    }];
    [modifiers addObject:mod];
    return YES;
}

@end
