//
//  ReckoningSpell.m
//  heal drudge
//
//  Created by david on 2/10/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ReckoningSpell.h"

@implementation ReckoningSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Reckoning";
        self.image = [ImageFactory imageNamed:@"reckoning"];
        self.tooltip = @"Taunts the target.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @8;
        self.spellType = DetrimentalSpell;
        self.castableRange = @30;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @(0.035 * caster.baseMana.floatValue);
        self.damage = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"taunt_cast_hit";
        self.hitSoundName = nil;
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    NSLog(@"RECKONING!!!! %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    //modifier.newTarget = self.caster;
    self.target.target = self.caster; // lol
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastWhenOtherTankNeedsTauntOff;
    return defaultPriority;
}

@end
