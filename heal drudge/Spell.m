//
//  Spell.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Spell.h"
#import "SpellPriv.h"

#import "Entity.h"

const NSString *SpellLevelLow = @"low";
const NSString *SpellLevelMedium = @"medium";
const NSString *SpellLevelHigh = @"high";

@implementation Spell

- (id)init
{
    [NSException raise:@"SpellWithoutCasterException" format:@"Tried to initialize %@ without a caster",NSStringFromClass([self class])];
    return nil;
}

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super init] )
    {
        self.caster = caster;
        if ( [[self hdClasses] containsObject:caster.hdClass] )
            PHLog(self,@"initializing %@'s %@",caster,self);
        else
            return nil;        
        self.level = @"low";
        self.hitSoundName = @"heal_hit";
        self.castSoundName = @"nature_cast";
    }
    return self;
}

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{
    return YES;
}

- (BOOL)addModifiers:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)handleTickWithModifier:(EventModifier *)modifier firstTick:(BOOL)firstTick
{
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
}

- (void)handleEndWithModifier:(EventModifier *)modifier
{
}

+ (NSArray *)castableSpellsForCharacter:(Entity *)player
{
    NSMutableArray *castableSpells = [NSMutableArray new];
    for ( NSString *spellName in [self _spellNames] )
    {
        Class spellClass = NSClassFromString(spellName);
        Spell *spell = [[spellClass alloc] initWithCaster:player];
        if ( spell )
            [castableSpells addObject:spell];
    }
    
    return castableSpells;
}

+ (NSArray *)_spellNames
{
    return @[
             @"PowerWordShieldSpell",
             @"HolyFireSpell",
             @"SmiteSpell",
             @"HealSpell",
             @"FlashHealSpell",
             @"ArchangelSpell",
             @"DivineStarSpell",
             @"PrayerOfMendingSpell",
             @"PrayerOfHealingSpell",
             @"PenanceSpell",
             @"PainSuppressionSpell",
             @"PowerWordBarrierSpell",
             
             @"DivineProtectionSpell",
             @"SacredShieldSpell",
             @"CrusaderStrikeSpell",
             @"GuardianOfAncientKingsSpell",
             @"ShieldOfTheRighteousSpell",
             @"WordOfGlorySpell",
             @"AvengersShieldSpell",
             @"LayOnHandsSpell",
             @"JudgementSpell",
             @"ArdentDefenderSpell",
             @"ReckoningSpell",
             
             @"HolyLightSpell",
             @"FlashOfLightSpell",
             @"HolyShockSpell",
             @"LightOfDawnSpell",
             @"DevotionAuraSpell",
             @"AvengingWrathSpell",
             @"HandOfSacrificeSpell",
             
             @"TauntSpell",
             
             @"GrowlSpell",
             
             @"ProvokeSpell",
             
             @"DarkCommandSpell",
             
             @"HealingTideTotemSpell",
             
             @"GenericHealingSpell",
             @"GenericDamageSpell",
             @"GenericPhysicalAttackSpell"
             ];
}

- (BOOL)isOnCooldown
{
    NSDate *storedDate = self.nextCooldownDate;
    return storedDate && [[NSDate date] timeIntervalSinceDateMinusPauseTime:storedDate] <= 0;
}

- (Effect *)_existingEffectWithClass:(Class)aClass
{
    __block Effect *existingEffect = nil;
    [self.caster.statusEffects enumerateObjectsUsingBlock:^(Effect *effect, NSUInteger idx, BOOL *stop) {
        if ( [effect isKindOfClass:aClass] )
        {
            existingEffect = effect;
            *stop = YES;
            return;
        }
    }];
    return existingEffect;
}

@end
