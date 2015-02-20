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

@import ObjectiveC.runtime;

const NSString *SpellLevelLow = @"low";
const NSString *SpellLevelMedium = @"medium";
const NSString *SpellLevelHigh = @"high";

@implementation Spell

@synthesize target = _target;

- (Entity *)target
{
    if ( self.inTransientStateExplosionMode )
        [NSException raise:@"TargetAccessedWhenNotInCastingState" format:@"%@",self];
    return _target;
}

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
            ;//PHLog(self,@"initializing %@'s %@",caster,self);
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
    for ( Class spellClass in [self _spellClasses] )
    {
        Spell *spell = [[spellClass alloc] initWithCaster:player];
        if ( spell )
            [castableSpells addObject:spell];
    }
    
    return castableSpells;
}

static NSArray *gSpellClasses = nil;
+ (NSArray *)_spellClasses
{
    // TODO not thread safe
    if ( ! gSpellClasses )
    {
        NSMutableArray *mutableSpellClasses = [NSMutableArray new];
        int numberOfClasses = objc_getClassList(NULL, 0);
        Class *classList = (__unsafe_unretained Class *)malloc(numberOfClasses * sizeof(Class));
        if ( classList )
        {
            numberOfClasses = objc_getClassList(classList, numberOfClasses);
            for (int idx = 0; idx < numberOfClasses; idx++)
            {
                Class class = classList[idx];
                if ( [NSStringFromClass(class) hasSuffix:@"Spell"] )
                {
                    Class superClassIter = class;
                    BOOL isSpellClass = NO;
                    while ( ( superClassIter = class_getSuperclass(superClassIter) ) )
                    {
                        if ( superClassIter == [Spell class] )
                        {
                            isSpellClass = YES;
                            break;
                        }
                    }
                    
                    if ( isSpellClass )
                        [mutableSpellClasses addObject:class];
                }
//                if ( [NSStringFromClass(class) hasSuffix:@"Spell"] &&
//                    (class_getInstanceMethod(class, @selector(initWithCaster:))) )
//                    [mutableSpellClasses addObject:class];
            }
            free(classList);
        }
        gSpellClasses = mutableSpellClasses;
        PHLogV(@"Initialized %ld spell classes",gSpellClasses.count);
    }
    return gSpellClasses;
    
//    return @[
//             @"PowerWordShieldSpell",
//             @"HolyFireSpell",
//             @"SmiteSpell",
//             @"HealSpell",
//             @"FlashHealSpell",
//             @"ArchangelSpell",
//             @"DivineStarSpell",
//             @"PrayerOfMendingSpell",
//             @"PrayerOfHealingSpell",
//             @"PenanceSpell",
//             @"PainSuppressionSpell",
//             @"PowerWordBarrierSpell",
//             @"MindBenderSpell",
//             @"HolyNovaSpell",
//             
//             @"DivineProtectionSpell",
//             @"SacredShieldSpell",
//             @"CrusaderStrikeSpell",
//             @"GuardianOfAncientKingsSpell",
//             @"ShieldOfTheRighteousSpell",
//             @"WordOfGlorySpell",
//             @"AvengersShieldSpell",
//             @"LayOnHandsSpell",
//             @"JudgementSpell",
//             @"ArdentDefenderSpell",
//             @"ReckoningSpell",
//             
//             @"HolyLightSpell",
//             @"FlashOfLightSpell",
//             @"HolyShockSpell",
//             @"LightOfDawnSpell",
//             @"DevotionAuraSpell",
//             @"AvengingWrathSpell",
//             @"HandOfSacrificeSpell",
//             
//             @"TemplarsVerdictSpell",
//             
//             @"TauntSpell",
//             
//             @"GrowlSpell",
//             
//             @"ProvokeSpell",
//             
//             @"DarkCommandSpell",
//             @"IceboundFortitudeSpell",
//             @"BoneShieldSpell",
//             @"AntiMagicShellSpell",
//             @"DancingRuneWeaponSpell",
//             
//             @"HealingTideTotemSpell",
//             
//             @"GenericHealingSpell",
//             @"GenericFastHealSpell",
//             @"GenericDamageSpell",
//             @"GenericPhysicalAttackSpell"
//             ];
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
