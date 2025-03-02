//
//  GrowlSpell.m
//  heal drudge
//
//  Created by david on 2/10/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GrowlSpell.h"

@implementation GrowlSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Growl";
        self.image = [ImageFactory imageNamed:@"growl"];
        self.tooltip = @"Taunts the target.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @8;
        self.spellType = DetrimentalSpell;
        self.castableRange = @30;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"taunt_cast_hit";
        self.hitSoundName = nil;
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    PHLog(self.caster,@"growl: %@ -> %@ instead of %@!",self.target,self.caster,self.target.target);
    //modifier.newTarget = self.caster;
    self.target.target = self.caster; // lol
}

- (NSArray *)hdClasses
{
    return @[ [HDClass feralDruid], [HDClass balanceDruid], [HDClass restoDruid] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastWhenOtherTankNeedsTauntOff;
    return defaultPriority;
}

@end
