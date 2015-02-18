//
//  HDClass.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

extern const NSString *HealerRole;
extern const NSString *DPSRole;
extern const NSString *TankRole;

typedef enum
{
    HDENEMYCLASS = 0,
    HDCLASSMIN = 1,
    HDWARRIOR = 1,
    HDPALADIN = 2,
    HDHUNTER = 3,
    HDROGUE = 4,
    HDPRIEST = 5,
    HDDEATHKNIGHT = 6,
    HDSHAMAN = 7,
    HDMAGE = 8,
    HDWARLOCK = 9,
    HDMONK = 10,
    HDDRUID = 11,
    HDCLASSMAX
} HDCLASSID;

// tauren == 6
// orc == 2
// undead == 5
// belf == 10
// human == 1
// 

typedef enum
{
    HDPRIESTSPECMIN = 0,
    HDHOLYPRIEST = HDPRIESTSPECMIN,
    HDDISCPRIEST,
    HDSHADOWPRIEST,
    
    HDPALADINSPECMIN,
    HDHOLYPALADIN = HDPALADINSPECMIN,
    HDPROTPALADIN,
    HDRETPALADIN,
    
    HDSHAMANSPECMIN,
    HDRESTOSHAMAN = HDSHAMANSPECMIN,
    HDENHANCESHAMAN,
    HDELESHAMAN,
    
    HDDRUIDSPECMIN,
    HDRESTODRUID = HDDRUIDSPECMIN,
    HDBALANCEDRUID,
    HDFERALDRUID,
    
    HDMONKSPECMIN,
    HDMISTWEAVERMONK = HDMONKSPECMIN,
    HDBREWMASTERMONK,
    HDWINDWALKERMONK,
    
    HDHUNTERSPECMIN,
    HDSURVIVALHUNTER = HDHUNTERSPECMIN,
    HDBEASTMASTERHUNTER,
    HDMARKSMANHUNTER,
    
    HDMAGESPECMIN,
    HDFROSTMAGE = HDMAGESPECMIN,
    HDFIREMAGE,
    HDARCANEMAGE,
    
    HDWARRIORSPECMIN,
    HDPROTWARRIOR = HDWARRIORSPECMIN,
    HDFURYWARRIOR,
    HDARMSWARRIOR,
    
    HDWARLOCKSPECMIN,
    HDDESTROWARLOCK = HDWARLOCKSPECMIN,
    HDAFFLICTIONWARLOCK,
    HDDEMONOLOGYWARLOCK,
    
    HDROGUESPECMIN,
    HDSUBTLETYROGUE = HDROGUESPECMIN,
    HDCOMBATROGUE,
    HDASSASSINATIONROGUE,
    
    HDDKSPECMIN,
    HDUNHOLYDK = HDDKSPECMIN,
    HDBLOODDK,
    HDFROSTDK,
    
    HDSPECMAX,
    
    HDENEMYSPEC
} HDSPECID;

@interface HDClass : NSObject
{
    HDCLASSID _classID;
    HDSPECID _specID;
}

@property (readonly) HDCLASSID classID;
@property (readonly) HDSPECID specID;
@property (readonly) UIColor *classColor;
@property (readonly) UIColor *resourceColor;
@property (readonly) UIColor *auxResourceColor;

+ (id)classWithID:(HDCLASSID)classID spec:(HDSPECID)specID;
+ (HDClass *)classWithAPICharacterDictionary:(NSDictionary *)apiDict apiSpecName:(NSString *)apiSpecName;
+ (HDClass *)randomClass;
+ (HDClass *)randomTankClass;
+ (HDClass *)randomHealerClass;
+ (HDClass *)randomDPSClass;
+ (HDClass *)enemyClass;

+ (BOOL)isHealerClass:(HDClass *)hdClass;
- (BOOL)isHealerClass;
- (NSString *)primaryStatKey;

- (BOOL)isRanged;
- (BOOL)isCasterDPS;
- (BOOL)isMeleeDPS;
- (BOOL)isTank;
- (BOOL)isDPS;
- (const NSString *)role;
- (BOOL)hasRole:(const NSString *)role;

+ (NSArray *)allClasses;
+ (NSArray *)allHealingClassSpecs;
+ (NSArray *)allGenericHealingClassSpecs;
+ (NSArray *)allCasterDPSClassSpecs;
+ (NSArray *)allMeleeClassSpecs;

+ (HDClass *)discPriest;
+ (HDClass *)holyPriest;
+ (HDClass *)shadowPriest;

+ (HDClass *)holyPaladin;
+ (HDClass *)protPaladin;
+ (HDClass *)retPaladin;

+ (HDClass *)restoShaman;
+ (HDClass *)eleShaman;
+ (HDClass *)enhanceShaman;

+ (HDClass *)restoDruid;
+ (HDClass *)feralDruid;
+ (HDClass *)balanceDruid;

+ (HDClass *)mistweaverMonk;
+ (HDClass *)windwalkerMonk;
+ (HDClass *)brewmasterMonk;

+ (HDClass *)combatRogue;
+ (HDClass *)subtletyRogue;
+ (HDClass *)assassinationRogue;

+ (HDClass *)destroWarlock;
+ (HDClass *)demoWarlock;
+ (HDClass *)afflictionWarlock;

+ (HDClass *)protWarrior;
+ (HDClass *)armsWarrior;
+ (HDClass *)furyWarrior;

+ (HDClass *)bloodDK;
+ (HDClass *)frostDK;
+ (HDClass *)unholyDK;

+ (HDClass *)bmHunter;
+ (HDClass *)survivalHunter;
+ (HDClass *)marksHunter;

+ (HDClass *)fireMage;
+ (HDClass *)frostMage;
+ (HDClass *)arcaneMage;

@end
