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
    {
        if ( ! [NSThread isMainThread] )
            //[NSException raise:@"TargetAccessedWhenNotInCastingState" format:@"%@",self];
            NSLog(@"*** TargetAccessedWhenNotInCastingState");
    }
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

+ (NSArray *)castableSpellsForCharacter:(Entity *)player orderedByNames:(NSArray *)orderedByNames
{
    NSMutableArray *castableSpells = [NSMutableArray new];
    NSArray *spellClasses = [self _spellClasses];
    
    if ( orderedByNames )
    {
        NSUInteger idx = 0;
        for( ; idx < orderedByNames.count; idx++ )
            [castableSpells addObject:[NSNull null]];
    }
    
    for ( Class spellClass in spellClasses )
    {
        Spell *spell = [[spellClass alloc] initWithCaster:player];
        if ( spell )
        {
            if ( orderedByNames && spell.name )
            {
                NSUInteger idx = [orderedByNames indexOfObject:spell.name];
                if ( idx == NSNotFound )
                    [castableSpells addObject:spell];
                [castableSpells replaceObjectAtIndex:idx withObject:spell];
            }
            else
                [castableSpells addObject:spell];
        }
    }
    
    NSUInteger idx = 0;
    for ( ; idx < castableSpells.count ; idx ++ )
    {
        id object = [castableSpells objectAtIndex:idx];
        if ( [object isEqual:[NSNull null]] )
        {
            [castableSpells removeObjectAtIndex:idx];
            PHLogV(@"Bug in spell ordering: %@'s castable spells contains NSNull at %lu",player,(unsigned long)idx);
        }
    }
    
    return castableSpells;
}

+ (void)prewarmSpellClasses
{
    [self _spellClasses];
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
        PHLogV(@"Initialized %ld spell classes",(unsigned long)gSpellClasses.count);
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
