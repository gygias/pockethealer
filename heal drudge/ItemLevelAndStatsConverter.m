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
    
    // tertiary
    // whatever for now
    float tertiaryScalar = 0.1;
    for ( NSString *tertiaryStatKey in [Entity tertiaryStatKeys] )
    {
        NSNumber *tertiaryStat = @( tertiaryScalar * ilvl.floatValue );
        [entity setValue:tertiaryStat forKey:tertiaryStatKey];
    }
    
    // these are to be synthesized?
    // attackPower
    // spellPower
    // defense
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
    if ( hdClass.isHealerClass )
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
    NSLog(@"%@'s gcd becomes %0.4fs faster with %@ haste and %@%% haste buff",entity,reduction,entity.hasteRating,hasteBuffPercentage?hasteBuffPercentage:@"0");
    return @( reduction > 1.5 ? 0 : 1.5 - reduction );
}

+ (NSNumber *)automaticHealValueWithEntity:(Entity *)entity
{
    return @( [entity.spellPower floatValue] * 3.3264 );
}

@end
