//
//  ItemLevelAndStatsConverter.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ItemLevelAndStatsConverter.h"

#import "Entity.h"
#import "HDClass.h"

#import "GenericDamageSpell.h"
#import "GenericPhysicalAttackSpell.h"

@implementation ItemLevelAndStatsConverter

+ (void)assignStatsToEntity:(Entity *)entity basedOnAverageEquippedItemLevel:(NSNumber *)ilvl
{
    // iliss 4448 (668) -
    //                  p/sta/sec
    //      630 head    167/251/223
    //      630 neck    94/141/124
    //      630 should. 126/189/164
    //      630 back    94/141/125
    //      630 chest   167/251/222
    //      630 wrist   94/141/120
    //      630 hands   126/189/166
    //      630 belt    126/189/165
    //      630 legs    167/251/222
    //      630 feet    126/189/164
    //      630 ring    94/141/124
    //      630 ring    "
    //      630 trinket 159p/159sec/proc?
    //      630 trinket 159p/159sec/proc?
    //      630 mh                  (167/251/214)
    //      630 oh      72/107/93
    //      ===============================
    //                  1960 (doesn't add up, more like 3k+)
    
    // chloesonderz 3526(636)   tako 4021(651)    iliss 4448(668)
    //              5.544       6.177             6.659
    entity.averageItemLevelEquipped = ilvl;
    
    NSInteger ilvlInt = ilvl.integerValue;
    
    float staminaScalar = 5.544; // 630
    if ( ilvlInt >= 668 )
        staminaScalar = 6.659;
    else if ( ilvlInt >= 650 )
        staminaScalar = 6.177;
    entity.stamina = @( staminaScalar * ilvl.floatValue );
    entity.power = [self maxPowerForClass:entity.hdClass];
    
    // primary stat
    // healer
    // tak 3284+1147(651)   yul 3599+1595(665)  lir 3698+1476(666)  il  3857+1170(668)
    // 2.863 i/s            2.256 i/s           2.505 i/s           3.297 i/s
    // 4431                 5194                5174                5027
    // 5.045                5.412               5.553               5.774
    float primaryScalar = 5.5;
    if ( ilvlInt <= 650 )
        primaryScalar = 5.0;
    NSString *myPrimaryStatKey = entity.hdClass.primaryStatKey;
    for ( NSString *primaryStatKey in [Entity primaryStatKeys] )
    {
        NSNumber *primaryStat = nil;
        if ( [primaryStatKey isEqual:myPrimaryStatKey] )
            primaryStat = @( primaryScalar * ilvl.floatValue );
        else
            primaryStat = @500; // whatever, it obviously gets a level-based base value
        [entity setValue:primaryStat forKey:primaryStatKey];
    }
    
    // secondary stat
    // healer
    //  tak 322m+1307c+855h gin 495m+877c+654h  lir 397m+852c+861h  il 1127m+697c+565h
    //  2484(3.816)         2026(3.088)         2110(3.168)         2389(3.576)
    float secondaryScalar = 3.4;
    for ( NSString *secondaryStatKey in [Entity secondaryStatKeys] )
    {
        NSNumber *secondaryStatsTotal = @( secondaryScalar * ilvl.floatValue );
        NSNumber *secondaryStatSplitEvenly = @( secondaryStatsTotal.integerValue / 3 );
        [entity setValue:secondaryStatSplitEvenly forKey:secondaryStatKey];
    }
    
    // taken from iliss with no spirit gear on
    entity.spirit = @787;
    
    // tertiary
    // whatever for now
    float tertiaryScalar = 0.1;
    for ( NSString *tertiaryStatKey in [Entity tertiaryStatKeys] )
    {
        NSNumber *tertiaryStat = @( tertiaryScalar * ilvl.floatValue );
        [entity setValue:tertiaryStat forKey:tertiaryStatKey];
    }
    
    if ( entity.hdClass.classID == HDPALADIN )
    {
        entity.maxAuxiliaryResources = @5;
        entity.auxResourceName = @"Holy Power";
    }
    else if ( entity.hdClass.classID == HDMONK )
    {
        entity.maxAuxiliaryResources = @5;
        entity.auxResourceName = @"Chi";
    }
    else if ( entity.hdClass.classID == HDROGUE )
    {
        entity.maxAuxiliaryResources = @5;
        entity.auxResourceName = @"Combo Point";
    }
    else if ( entity.hdClass.specID == HDDESTROWARLOCK ) // TODO i'm not sure what other specs have
    {
        entity.maxAuxiliaryResources = @5;
        entity.auxResourceName = @"Burning Ember";
    }
    else if ( entity.hdClass.classID == HDDEATHKNIGHT )
    {
        entity.maxAuxiliaryResources = @6;
        entity.auxResourceName = @"Runes"; // this isn't going to work with 4 types of runes
    }
    
    // avoidance
    // analog   644     2914 armor + 629 bonus 5    986 parry       5% dodge    19.38% block
    // savin    665     2872 armor + 576 bonus 5    765 parry       5% dodge    22.11% block
    // slyeri   662     3155 armor + 458 bonus 4    634 parry       5% dodge    35.60% block
    // prot pally mastery: increases damage reduction of sotr by 7%, adds 7% to bastion, increases block by 10%, increases attack power by 10%
    // whatever, do this in game, armory seems to be inconsistent
    // savin 665 3448 - analog 644 3085 = 21 363
    // 17.28571428571429 armor per ilvl
    // cloth: iliss 671 729 - kepheus 644 596 = 27 133
    // 4.92592592592593 armor per ilvl
    float armorScalar = ( entity.hdClass.isTank ? 17.28571428571429 : 4.92592592592593);
    entity.armor = @( armorScalar * ilvl.floatValue );
    // TODO (986 + 765 + 634)/3[795] / (644 + 665 + 662)/3[657]
    // 1.21004566210046 parry per ilvl
    float parryScalar = ( entity.hdClass.isTank ? 1.21004566210046 : 0 );
    entity.parryRating = @( parryScalar * ilvl.floatValue );
    if ( entity.hdClass.isTank )
        entity.dodgeChance = @( entity.hdClass.isTank ? .05 : .03 );
    entity.blockChance = @( entity.hdClass.isTank ? .2 : 0 );
    
    // these are to be synthesized?
    // attackPower
    // spellPower
}

+ (NSNumber *)spellPowerFromIntellect:(NSNumber *)intellect
{
    // tak 4155(3284)   yul 4808(3599)  lir 4907(3698)  5066(3857)
    //  1.265           1.336           1.327           1.313
    return @( 1.3 * intellect.floatValue );
}

+ (NSNumber *)healthFromStamina:(NSNumber *)stamina
{
    // tak 241260(4021) yul 258060(4301) lir 262620(4377)   il 266880(4448)
    //  60              60                  60              60
    return @( 60 * stamina.integerValue );
}

+ (NSNumber *)critBonusFromIntellect:(NSNumber *)intellect
{
    // http://us.battle.net/wow/en/blog/13423478/warlords-of-draenor™-beta-patch-notes-august-1-8-1-2014#character_stats
    // "Intellect no longer provides an increased chance to critically strike with spells."
    return @0;
}

+ (NSNumber *)attackPowerBonusFromAgility:(NSNumber *)agility andStrength:(NSNumber *)strength
{
    return @( agility.integerValue + strength.integerValue ); // was 2, now 1, see above link
}

+ (NSNumber *)critBonusFromAgility:(NSNumber *)agility
{
    return @0; // scaling with agility was removed in wod, though there seems to be a static 5% bonus
}

+ (NSNumber *)maxPowerForClass:(HDClass *)hdClass
{
    if ( hdClass.isHealerClass || hdClass.isCasterDPS )
        return @160000;
    return @100; // XXX prot/ret pally, etc
}

+ (NSNumber *)castTimeWithBaseCastTime:(NSNumber *)baseCastTime entity:(Entity *)entity hasteBuffPercentage:(NSNumber *)hasteBuffPercentage
{
    // iliss 671, 679 haste
    // heal 2.33 sec cast
    // naked 2.5 sec cast
    // 2.5 - 2.33 / 679 =  0.00025036818851
    //
    // flash heal 1.39 sec cast
    // naked 1.5 sec cast
    // 1.5 - 1.39 / 679 =  0.00016200294551
    //
    // penance 1.86 sec tick
    // naked 2 sec
    // 2 - 1.86 / 679 =    0.00020618556701
    
    // there seems to be some kind of curve to this relationship
    // average = 0.00020618556701 secs per haste
    double buffRating = ( entity.hasteRating.doubleValue * ( 1 + hasteBuffPercentage.doubleValue ) );
    double reduction = ( buffRating * 0.00020618556701 );
    NSLog(@"%@ cast time becomes %0.4fs faster with %@'s %@ haste and %@%% haste buff",baseCastTime,reduction,entity,entity.hasteRating,hasteBuffPercentage?hasteBuffPercentage:@"0");
    return @( reduction > baseCastTime.doubleValue ? 0 : baseCastTime.doubleValue - reduction );
}

+ (NSNumber *)globalCooldownWithEntity:(Entity *)entity hasteBuffPercentage:(NSNumber *)hasteBuffPercentage
{
    // iliss 671 679 haste
    // 1.5 - 1.394 / 679 =  0.00015611192931
    // 951 with borrowed time (in fact 1.4 * hasteRating :)
    // 1.5 - 1.356 / 951 =  0.00015141955836
    // average = 0.00015376574384
    double buffRating = ( entity.hasteRating.doubleValue * ( 1 + hasteBuffPercentage.doubleValue ) );
    double reduction = ( buffRating * 0.00015376574384 );
    //NSLog(@"%@'s gcd becomes %0.4fs faster with %@ haste and %@%% haste buff",entity,reduction,entity.hasteRating,hasteBuffPercentage?hasteBuffPercentage:@"0");
    return @( reduction > 1.5 ? 0 : 1.5 - reduction );
}

#define RAGE_PER_SECOND 20.0
#define ENERGY_PER_SECOND 20.0
#define FOCUS_PER_SECOND 20.0
#define RUNIC_POWER_PER_SECOND 20.0
#define CASTER_MANA_PER_SECOND 500.0

+ (NSNumber *)resourceGenerationWithEntity:(Entity *)entity timeInterval:(NSTimeInterval)timeInterval
{
    if ( entity.hdClass.isHealerClass )
    {
        // iliss 671
        // 80k mana in 69.73 seconds with 1170 spirit
        // 40k mana in 41.18 seconds with 787 spirit (base)
        // 80k / 69.73 = 1147.28 mpsecond
        // 40k / 41.18 = 971.34 mpsecond
        // (1147.28 - 971.34) / (1170 - 787) =
        //  175.94 / 383 = 0.45937336814621 mana per second per spirit
        return @( 0.45937 * entity.spirit.doubleValue * timeInterval );
    }
    else if ( entity.hdClass.isCasterDPS )
    {
        return @( CASTER_MANA_PER_SECOND * timeInterval );
    }
    
    switch( entity.hdClass.classID )
    {
        case HDWARRIOR:
            return @( RAGE_PER_SECOND * timeInterval );
        case HDHUNTER:
            return @( FOCUS_PER_SECOND * timeInterval );
        case HDDEATHKNIGHT:
            return @( RUNIC_POWER_PER_SECOND * timeInterval );
        case HDPALADIN: // prot or ret per above
            return @( CASTER_MANA_PER_SECOND * timeInterval / 10 );
        case HDDRUID: // feral per above
        case HDMONK: // brewmaster or windwalker per above
        case HDROGUE:
            return @( ENERGY_PER_SECOND * timeInterval );
        default:
            break;
    }
    
    return @0;
}

+ (NSNumber *)automaticHealValueWithEntity:(Entity *)entity
{
    return @( [entity.spellPower floatValue] * 3.3264 );
}

+ (NSNumber *)averageDPSOfEntities:(NSArray *)entities
{
    __block double averageDPS = 0;
    [entities enumerateObjectsUsingBlock:^(Entity *entity, NSUInteger idx, BOOL *stop) {
        Spell *spell = nil;
        if ( entity.hdClass.isCasterDPS )
            spell = [[GenericDamageSpell alloc] initWithCaster:entity];
        else if ( entity.hdClass.isMeleeDPS || entity.hdClass.isTank )
            spell = [[GenericPhysicalAttackSpell alloc] initWithCaster:entity];
        
        NSNumber *entityGcd = [self globalCooldownWithEntity:entity hasteBuffPercentage:nil];
        if ( spell.cooldown.doubleValue > 0 )
            averageDPS += spell.damage.doubleValue / ( ( spell.cooldown.doubleValue > entityGcd.doubleValue ) ? spell.cooldown.doubleValue : entityGcd.doubleValue );
        else
            averageDPS += spell.damage.doubleValue / entityGcd.doubleValue;
    }];
    
    return @(averageDPS);
}

@end
