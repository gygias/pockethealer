//
//  HDClass.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HDClass.h"

#define SPECS_PER_CLASS 3

const NSString *HealerRole = @"HEALING";
const NSString *DPSRole = @"DPS";
const NSString *TankRole = @"TANK";

@implementation HDClass

@synthesize classID = _classID, specID = _specID;

+ (HDClass *)enemyClass
{
    return [HDClass classWithID:HDENEMYCLASS spec:HDENEMYSPEC];
}

+ (HDClass *)randomClass
{
    HDCLASSID someClassID = arc4random() % HDCLASSMAX;
    if ( someClassID <= HDCLASSMIN ) someClassID = HDCLASSMIN;
    HDSPECID someSpecIDBase = ( arc4random() % SPECS_PER_CLASS );
    HDSPECID someSpecID = 0;
    if ( someClassID == HDPRIEST )
        someSpecID = HDPRIESTSPECMIN + someSpecIDBase;
    if ( someClassID == HDPALADIN )
        someSpecID = HDPALADINSPECMIN + someSpecIDBase;
    if ( someClassID == HDDRUID )
        someSpecID = HDDRUIDSPECMIN + someSpecIDBase;
    if ( someClassID == HDSHAMAN )
        someSpecID = HDSHAMANSPECMIN + someSpecIDBase;
    if ( someClassID == HDMONK )
        someSpecID = HDMONKSPECMIN + someSpecIDBase;
    if ( someClassID == HDROGUE )
        someSpecID = HDROGUESPECMIN + someSpecIDBase;
    if ( someClassID == HDWARRIOR )
        someSpecID = HDWARRIORSPECMIN + someSpecIDBase;
    if ( someClassID == HDWARLOCK )
        someSpecID = HDWARLOCKSPECMIN + someSpecIDBase;
    if ( someClassID == HDDEATHKNIGHT )
        someSpecID = HDDKSPECMIN + someSpecIDBase;
    if ( someClassID == HDHUNTER )
        someSpecID = HDHUNTERSPECMIN + someSpecIDBase;
    if ( someClassID == HDMAGE )
        someSpecID = HDMAGESPECMIN + someSpecIDBase;
    return [HDClass classWithID:someClassID spec:someSpecID];
}

+ (HDClass *)randomTankClass
{
    HDClass *randomClass = nil;
    do
    {
        randomClass = [HDClass randomClass];
    } while ( ! randomClass.isTank );
    return randomClass;
}

+ (HDClass *)randomHealerClass
{
    return [HDClass discPriest];
    HDClass *randomClass = nil;
    do
    {
        randomClass = [HDClass randomClass];
    } while ( ! randomClass.isHealerClass );
    return randomClass;
}

+ (HDClass *)randomDPSClass
{
    HDClass *randomClass = nil;
    do
    {
        randomClass = [HDClass randomClass];
    } while ( ! randomClass.isDPS );
    return randomClass;
}

- (id)_initWithID:(HDCLASSID)classID spec:(HDSPECID)specID
{
    if ( self = [super init] )
    {
        _classID = classID;
        _specID = specID;
    }
    return self;
}

+ (id)classWithID:(HDCLASSID)classID spec:(HDSPECID)specID
{
    return [[HDClass alloc] _initWithID:classID spec:specID];
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[HDClass class]] )
        return NO;
    HDClass *otherClass = (HDClass *)object;
    return otherClass.classID == self.classID
            && otherClass.specID == self.specID;
}

+ (BOOL)isHealerClass:(HDClass *)hdClass
{
    return [hdClass isHealerClass];
}

- (BOOL)isHealerClass
{
    HDSPECID spec = _specID;
    return spec == HDDISCPRIEST ||
            spec == HDHOLYPRIEST ||
            spec == HDHOLYPALADIN ||
            spec == HDRESTODRUID ||
            spec == HDRESTOSHAMAN ||
            spec == HDMISTWEAVERMONK;
}

const NSString *WoWAPIClassKey = @"class";

+ (HDClass *)classWithAPICharacterDictionary:(NSDictionary *)apiDict apiSpecName:(NSString *)apiSpecName
{
    NSNumber *classNumber = apiDict[WoWAPIClassKey];
    HDCLASSID classID = [classNumber unsignedIntValue];
    HDSPECID specID = 0;
    switch(classID)
    {
        case HDPRIEST:
            if ( [apiSpecName rangeOfString:@"disc" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDDISCPRIEST;
            else if ( [apiSpecName rangeOfString:@"holy" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDHOLYPRIEST;
            else if ( [apiSpecName rangeOfString:@"shadow" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDSHADOWPRIEST;
            else
                specID = HDDISCPRIEST;
            break;
        case HDPALADIN:
            if ( [apiSpecName rangeOfString:@"holy" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDHOLYPALADIN;
            else if ( [apiSpecName rangeOfString:@"prot" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDPROTPALADIN;
            else if ( [apiSpecName rangeOfString:@"ret" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDRETPALADIN;
            else
                specID = HDHOLYPALADIN;
            break;
            break;
        case HDSHAMAN:
            if ( [apiSpecName rangeOfString:@"resto" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDRESTOSHAMAN;
            else if ( [apiSpecName rangeOfString:@"ele" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDELESHAMAN;
            else if ( [apiSpecName rangeOfString:@"enh" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDENHANCESHAMAN;
            else
                specID = HDRESTOSHAMAN;
            break;
        case HDDRUID:
            if ( [apiSpecName rangeOfString:@"resto" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDRESTODRUID;
            else if ( [apiSpecName rangeOfString:@"guard" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFERALDRUID;
            else if ( [apiSpecName rangeOfString:@"feral" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFERALDRUID;
            else if ( [apiSpecName rangeOfString:@"bal" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDBALANCEDRUID;
            else
                specID = HDRESTODRUID;
            break;
        case HDMONK:
            if ( [apiSpecName rangeOfString:@"mist" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDMISTWEAVERMONK;
            else if ( [apiSpecName rangeOfString:@"wind" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDWINDWALKERMONK;
            else if ( [apiSpecName rangeOfString:@"brew" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDBREWMASTERMONK;
            else
                specID = HDMISTWEAVERMONK;
            break;
        case HDHUNTER:
            if ( [apiSpecName rangeOfString:@"beast" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDBEASTMASTERHUNTER;
            else if ( [apiSpecName rangeOfString:@"surv" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDSURVIVALHUNTER;
            else if ( [apiSpecName rangeOfString:@"mark" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDMARKSMANHUNTER;
            else
                specID = HDBEASTMASTERHUNTER;
            break;
        case HDMAGE:
            if ( [apiSpecName rangeOfString:@"fire" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFIREMAGE;
            else if ( [apiSpecName rangeOfString:@"frost" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFROSTMAGE;
            else if ( [apiSpecName rangeOfString:@"arc" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDARCANEMAGE;
            else
                specID = HDFIREMAGE;
            break;
        case HDWARRIOR:
            if ( [apiSpecName rangeOfString:@"fury" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFURYWARRIOR;
            else if ( [apiSpecName rangeOfString:@"arms" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDARMSWARRIOR;
            else if ( [apiSpecName rangeOfString:@"prot" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDPROTWARRIOR;
            else
                specID = HDFURYWARRIOR;
            break;
        case HDWARLOCK:
            if ( [apiSpecName rangeOfString:@"dest" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDDESTROWARLOCK;
            else if ( [apiSpecName rangeOfString:@"demo" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDDEMONOLOGYWARLOCK;
            else if ( [apiSpecName rangeOfString:@"aff" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDAFFLICTIONWARLOCK;
            else
                specID = HDDESTROWARLOCK;
            break;
        case HDROGUE:
            if ( [apiSpecName rangeOfString:@"comb" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDCOMBATROGUE;
            else if ( [apiSpecName rangeOfString:@"sub" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDSUBTLETYROGUE;
            else if ( [apiSpecName rangeOfString:@"ass" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDASSASSINATIONROGUE;
            else
                specID = HDCOMBATROGUE;
            break;
        case HDDEATHKNIGHT:
            if ( [apiSpecName rangeOfString:@"unh" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDUNHOLYDK;
            else if ( [apiSpecName rangeOfString:@"blo" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDBLOODDK;
            else if ( [apiSpecName rangeOfString:@"fro" options:NSCaseInsensitiveSearch].location != NSNotFound )
                specID = HDFROSTDK;
            else
                specID = HDUNHOLYDK;
            break;
        case HDCLASSMAX:
            break;
        default:
            break;
    }
    
    return [HDClass classWithID:classID spec:specID];
}

- (UIColor *)classColor
{
    switch(_classID)
    {
        case HDPRIEST:
            return [UIColor whiteColor];
            break;
        case HDPALADIN:
            return [UIColor pinkColor];
            break;
        case HDSHAMAN:
            return [UIColor blueColor];
            break;
        case HDDRUID:
            return [UIColor orangeColor];
            break;
        case HDMONK:
            return [UIColor greenColor];
            break;
        case HDHUNTER:
            return [UIColor greenColor];
            break;
        case HDMAGE:
            return [UIColor cyanColor];
            break;
        case HDWARRIOR:
            return [UIColor brownColor];
            break;
        case HDWARLOCK:
            return [UIColor purpleColor];
            break;
        case HDROGUE:
            return [UIColor yellowColor];
            break;
        case HDDEATHKNIGHT:
            return [UIColor redColor];
            break;
        case HDENEMYCLASS:
            return [UIColor redColor];
            break;
        default:
            break;
    }
    
    return [UIColor blackColor];
}

- (UIColor *)resourceColor
{
    switch(_classID)
    {
        case HDPRIEST:
            return [UIColor blueColor];
            break;
        case HDPALADIN:
            return [UIColor blueColor];
            break;
        case HDSHAMAN:
            return [UIColor blueColor];
            break;
        case HDDRUID:
            if ( _specID == HDFERALDRUID )
                return [UIColor yellowColor];
            return [UIColor blueColor];
            break;
        case HDMONK:
            return [UIColor blueColor];
            break;
        case HDHUNTER:
            return [UIColor yellowColor];
            break;
        case HDMAGE:
            return [UIColor blueColor];
            break;
        case HDWARRIOR:
            return [UIColor redColor];
            break;
        case HDWARLOCK:
            return [UIColor blueColor];
            break;
        case HDROGUE:
            return [UIColor yellowColor];
            break;
        case HDDEATHKNIGHT:
            return [UIColor cyanColor];
            break;
        default:
            break;
    }
    
    return [UIColor blackColor];
}

- (UIColor *)auxResourceColor
{
    switch (_classID) {
        case HDPALADIN:
            return [UIColor yellowColor];
            break;
        case HDMONK:
            return [UIColor cyanColor];
            break;
        case HDROGUE:
            return [UIColor redColor];
            break;
        default:
            break;
    }
    
    switch (_specID) {
        case HDSHADOWPRIEST:
            return [UIColor purpleColor];
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSString *)description
{
    NSString *specString = @"xspecx",
            *classString = @"xclassx";
    switch(_classID)
    {
        case HDPRIEST:
            classString = @"priest";
            switch(_specID)
            {
                case HDHOLYPRIEST:
                    specString = @"holy";
                    break;
                case HDDISCPRIEST:
                    specString = @"discipline";
                    break;
                case HDSHADOWPRIEST:
                    specString = @"shadow";
                    break;
                default:
                    break;
            }
            break;
        case HDPALADIN:
            classString = @"paladin";
            switch(_specID)
            {
                case HDHOLYPALADIN:
                    specString = @"holy";
                    break;
                case HDPROTPALADIN:
                    specString = @"protection";
                    break;
                case HDRETPALADIN:
                    specString = @"retribution";
                    break;
                default:
                    break;
            }
            break;
        case HDSHAMAN:
            classString = @"shaman";
            switch(_specID)
            {
                case HDRESTOSHAMAN:
                    specString = @"restoration";
                    break;
                case HDENHANCESHAMAN:
                    specString = @"enhancement";
                    break;
                case HDELESHAMAN:
                    specString = @"elemental";
                    break;
                default:
                    break;
            }
            break;
        case HDDRUID:
            classString = @"druid";
            switch(_specID)
            {
                case HDRESTODRUID:
                    specString = @"restoration";
                    break;
                case HDBALANCEDRUID:
                    specString = @"balance";
                    break;
                case HDFERALDRUID:
                    specString = @"feral";
                    break;
                default:
                    break;
            }
            break;
        case HDMONK:
            classString = @"monk";
            switch(_specID)
            {
                case HDMISTWEAVERMONK:
                    specString = @"mistweaver";
                    break;
                case HDBREWMASTERMONK:
                    specString = @"brewmaster";
                    break;
                case HDWINDWALKERMONK:
                    specString = @"windwalker";
                    break;
                default:
                    break;
            }
            break;
        case HDHUNTER:
            classString = @"hunter";
            switch(_specID)
            {
                case HDSURVIVALHUNTER:
                    specString = @"survival";
                    break;
                case HDBEASTMASTERHUNTER:
                    specString = @"beast master";
                    break;
                case HDMARKSMANHUNTER:
                    specString = @"marksman";
                    break;
                default:
                    break;
            }
            break;
        case HDMAGE:
            classString = @"mage";
            switch(_specID)
            {
                case HDFROSTMAGE:
                    specString = @"frost";
                    break;
                case HDFIREMAGE:
                    specString = @"fire";
                    break;
                case HDARCANEMAGE:
                    specString = @"arcane";
                    break;
                default:
                    break;
            }
            break;
        case HDWARRIOR:
            classString = @"warrior";
            switch(_specID)
            {
                case HDPROTWARRIOR:
                    specString = @"protection";
                    break;
                case HDFURYWARRIOR:
                    specString = @"fury";
                    break;
                case HDARMSWARRIOR:
                    specString = @"arms";
                    break;
                default:
                    break;
            }
            break;
        case HDWARLOCK:
            classString = @"warlock";
            switch(_specID)
            {
                case HDDESTROWARLOCK:
                    specString = @"destruction";
                    break;
                case HDAFFLICTIONWARLOCK:
                    specString = @"affliction";
                    break;
                case HDDEMONOLOGYWARLOCK:
                    specString = @"demonology";
                    break;
                default:
                    break;
            }
            break;
        case HDROGUE:
            classString = @"rogue";
            switch(_specID)
            {
                case HDSUBTLETYROGUE:
                    specString = @"subtlety";
                    break;
                case HDCOMBATROGUE:
                    specString = @"combat";
                    break;
                case HDASSASSINATIONROGUE:
                    specString = @"assassination";
                    break;
                default:
                    break;
            }
            break;
        case HDDEATHKNIGHT:
            classString = @"deathknight";
            switch(_specID)
            {
                case HDUNHOLYDK:
                    specString = @"unholy";
                    break;
                case HDBLOODDK:
                    specString = @"blood";
                    break;
                case HDFROSTDK:
                    specString = @"frost";
                    break;
                default:
                    break;
            }
            break;
        case HDENEMYCLASS:
            classString = @"enemy class";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@",specString,classString];
}

- (BOOL)isRanged
{
    switch (_specID)
    {
        case HDDISCPRIEST:
        case HDHOLYPRIEST:
        case HDHOLYPALADIN:
        case HDRESTOSHAMAN:
        case HDRESTODRUID:
        case HDMISTWEAVERMONK:            
        case HDSHADOWPRIEST:
        case HDELESHAMAN:
        case HDBALANCEDRUID:
        case HDBEASTMASTERHUNTER:
        case HDSURVIVALHUNTER:
        case HDMARKSMANHUNTER:
        case HDFIREMAGE:
        case HDFROSTMAGE:
        case HDARCANEMAGE:
        case HDDESTROWARLOCK:
        case HDDEMONOLOGYWARLOCK:
        case HDAFFLICTIONWARLOCK:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isCasterDPS
{
    switch (_classID)
    {
        case HDWARLOCK:
        case HDMAGE:
        case HDHUNTER: // TODO
            return YES;
            break;
        default:
            break;
    }
    
    switch (_specID)
    {
        case HDSHADOWPRIEST:
        case HDELESHAMAN:
        case HDBALANCEDRUID:
            return YES;
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)isMeleeDPS
{
    switch (_classID)
    {
        case HDROGUE:
            return YES;
            break;
        default:
            break;
    }
    
    switch (_specID)
    {
        case HDENHANCESHAMAN:
        case HDFURYWARRIOR:
        case HDARMSWARRIOR:
        case HDWINDWALKERMONK:
        case HDRETPALADIN:
        case HDFERALDRUID:
        case HDUNHOLYDK:
        case HDFROSTDK:
            return YES;
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)isTank
{
    switch (_specID)
    {
        case HDPROTPALADIN:
        case HDPROTWARRIOR:
        case HDBLOODDK:
        case HDBREWMASTERMONK:
            return YES;
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)isDPS
{
    return [self isCasterDPS] || [self isMeleeDPS];
}

- (const NSString *)role
{
    switch (_specID)
    {
        case HDDISCPRIEST:
        case HDHOLYPRIEST:
        case HDHOLYPALADIN:
        case HDRESTOSHAMAN:
        case HDRESTODRUID:
        case HDMISTWEAVERMONK:
            return HealerRole;
        case HDPROTPALADIN:
        case HDPROTWARRIOR:
        case HDBLOODDK:
        case HDBREWMASTERMONK:
            return TankRole;
        case HDSHADOWPRIEST:
        case HDRETPALADIN:
        case HDELESHAMAN:
        case HDENHANCESHAMAN:
        case HDBALANCEDRUID:
        case HDFERALDRUID:
        case HDWINDWALKERMONK:
        case HDBEASTMASTERHUNTER:
        case HDSURVIVALHUNTER:
        case HDMARKSMANHUNTER:
        case HDFIREMAGE:
        case HDFROSTMAGE:
        case HDARCANEMAGE:
        case HDFURYWARRIOR:
        case HDARMSWARRIOR:
        case HDDESTROWARLOCK:
        case HDDEMONOLOGYWARLOCK:
        case HDAFFLICTIONWARLOCK:
        case HDCOMBATROGUE:
        case HDSUBTLETYROGUE:
        case HDASSASSINATIONROGUE:
        case HDUNHOLYDK:
        case HDFROSTDK:
            return DPSRole;
        default:
            return nil;
    }
    
    return nil;
}

- (BOOL)hasRole:(const NSString *)role
{
    return [[self role] isEqualToString:(NSString *)role];
}

- (NSString *)primaryStatKey
{
    switch(_classID)
    {
        case HDPRIEST:
            return @"intellect";
            break;
        case HDPALADIN:
            if ( _specID == HDHOLYPALADIN )
                return @"intellect";
            return @"strength";
            break;
        case HDSHAMAN:
            if ( _specID == HDENHANCESHAMAN )
                return @"agility";
            return @"intellect";
            break;
        case HDDRUID:
            if ( _specID == HDFERALDRUID )
                return @"agility";
            return @"intellect";
            break;
        case HDMONK:
            if ( _specID == HDMISTWEAVERMONK )
                return @"intellect";
            return @"agility";
            break;
        case HDHUNTER:
            return @"agility";
            break;
        case HDMAGE:
            return @"intellect";
            break;
        case HDWARRIOR:
            return @"strength";
            break;
        case HDWARLOCK:
            return @"intellect";
            break;
        case HDROGUE:
            return @"agility";
            break;
        case HDDEATHKNIGHT:
            return @"strength";
            break;
        default:
            break;
    }
    
    PHLogV(@"bug at -primaryStatName");
    return @"intellect";
}

+ (HDClass *)discPriest { return [HDClass classWithID:HDPRIEST spec:HDDISCPRIEST]; }
+ (HDClass *)holyPriest { return [HDClass classWithID:HDPRIEST spec:HDHOLYPRIEST]; }
+ (HDClass *)shadowPriest { return [HDClass classWithID:HDPRIEST spec:HDSHADOWPRIEST]; }

+ (HDClass *)holyPaladin { return [HDClass classWithID:HDPALADIN spec:HDHOLYPALADIN]; }
+ (HDClass *)protPaladin { return [HDClass classWithID:HDPALADIN spec:HDPROTPALADIN]; }
+ (HDClass *)retPaladin { return [HDClass classWithID:HDPALADIN spec:HDRETPALADIN]; }

+ (HDClass *)restoShaman { return [HDClass classWithID:HDSHAMAN spec:HDRESTOSHAMAN]; }
+ (HDClass *)eleShaman { return [HDClass classWithID:HDSHAMAN spec:HDELESHAMAN]; }
+ (HDClass *)enhanceShaman { return [HDClass classWithID:HDSHAMAN spec:HDENHANCESHAMAN]; }

+ (HDClass *)restoDruid { return [HDClass classWithID:HDDRUID spec:HDRESTODRUID]; }
+ (HDClass *)feralDruid { return [HDClass classWithID:HDDRUID spec:HDFERALDRUID]; }
+ (HDClass *)balanceDruid { return [HDClass classWithID:HDDRUID spec:HDBALANCEDRUID]; }

+ (HDClass *)mistweaverMonk { return [HDClass classWithID:HDMONK spec:HDMISTWEAVERMONK]; }
+ (HDClass *)windwalkerMonk { return [HDClass classWithID:HDMONK spec:HDWINDWALKERMONK]; }
+ (HDClass *)brewmasterMonk { return [HDClass classWithID:HDMONK spec:HDBREWMASTERMONK]; }

+ (HDClass *)combatRogue  { return [HDClass classWithID:HDROGUE spec:HDCOMBATROGUE]; }
+ (HDClass *)subtletyRogue { return [HDClass classWithID:HDROGUE spec:HDSUBTLETYROGUE]; }
+ (HDClass *)assassinationRogue { return [HDClass classWithID:HDROGUE spec:HDASSASSINATIONROGUE]; }

+ (HDClass *)destroWarlock { return [HDClass classWithID:HDWARLOCK spec:HDDESTROWARLOCK]; }
+ (HDClass *)demoWarlock { return [HDClass classWithID:HDWARLOCK spec:HDDEMONOLOGYWARLOCK]; }
+ (HDClass *)afflictionWarlock { return [HDClass classWithID:HDWARLOCK spec:HDAFFLICTIONWARLOCK]; }

+ (HDClass *)protWarrior { return [HDClass classWithID:HDWARRIOR spec:HDPROTWARRIOR]; }
+ (HDClass *)armsWarrior { return [HDClass classWithID:HDWARRIOR spec:HDARMSWARRIOR]; }
+ (HDClass *)furyWarrior { return [HDClass classWithID:HDWARRIOR spec:HDFURYWARRIOR]; }

+ (HDClass *)bloodDK { return [HDClass classWithID:HDDEATHKNIGHT spec:HDBLOODDK]; }
+ (HDClass *)frostDK { return [HDClass classWithID:HDDEATHKNIGHT spec:HDFROSTDK]; }
+ (HDClass *)unholyDK { return [HDClass classWithID:HDDEATHKNIGHT spec:HDUNHOLYDK]; }

+ (HDClass *)bmHunter { return [HDClass classWithID:HDHUNTER spec:HDBEASTMASTERHUNTER]; }
+ (HDClass *)survivalHunter { return [HDClass classWithID:HDHUNTER spec:HDSURVIVALHUNTER]; }
+ (HDClass *)marksHunter { return [HDClass classWithID:HDHUNTER spec:HDMARKSMANHUNTER]; }

+ (HDClass *)fireMage { return [HDClass classWithID:HDMAGE spec:HDFIREMAGE]; }
+ (HDClass *)frostMage { return [HDClass classWithID:HDMAGE spec:HDFROSTMAGE]; }
+ (HDClass *)arcaneMage { return [HDClass classWithID:HDMAGE spec:HDARCANEMAGE]; }

+ (NSArray *)allClasses
{
    return @[ [self discPriest], [self holyPriest], [self shadowPriest],
              [self holyPaladin], [self protPaladin], [self retPaladin],
              [self restoShaman], [self eleShaman], [self enhanceShaman],
              [self restoDruid], [self feralDruid], [self balanceDruid],
              [self mistweaverMonk], [self windwalkerMonk], [self brewmasterMonk],
              [self combatRogue], [self subtletyRogue], [self assassinationRogue],
              [self destroWarlock], [self demoWarlock], [self afflictionWarlock],
              [self protWarrior], [self armsWarrior], [self furyWarrior],
              [self bloodDK], [self frostDK], [self unholyDK],
              [self bmHunter], [self survivalHunter], [self marksHunter],
              [self fireMage], [self frostMage], [self arcaneMage]
              ];
}

+ (NSArray *)_allHealingClassSpecsExcluding:(BOOL)excluding
{
    NSMutableArray *allHealingClassSpecs = [NSMutableArray new];
    [[self allClasses] enumerateObjectsUsingBlock:^(HDClass *aClass, NSUInteger idx, BOOL *stop) {
        if ( aClass.isHealerClass )
        {
            if ( excluding && (
                                [aClass isEqual:[HDClass discPriest]] ||
                                [aClass isEqual:[HDClass holyPaladin]]
                               )
                )
                return;
            
            [allHealingClassSpecs addObject:aClass];
        }
    }];
    return allHealingClassSpecs;
}

+ (NSArray *)allHealingClassSpecs
{
    return [self _allHealingClassSpecsExcluding:NO];
}

+ (NSArray *)allGenericHealingClassSpecs
{
    return [self _allHealingClassSpecsExcluding:YES];
}

+ (NSArray *)allCasterDPSClassSpecs
{
    NSMutableArray *allHealingClassSpecs = [NSMutableArray new];
    [[self allClasses] enumerateObjectsUsingBlock:^(HDClass *aClass, NSUInteger idx, BOOL *stop) {
        if ( aClass.isCasterDPS )
            [allHealingClassSpecs addObject:aClass];
    }];
    return allHealingClassSpecs;
}

+ (NSArray *)allMeleeClassSpecs
{
    NSMutableArray *allHealingClassSpecs = [NSMutableArray new];
    [[self allClasses] enumerateObjectsUsingBlock:^(HDClass *aClass, NSUInteger idx, BOOL *stop) {
        if ( aClass.isMeleeDPS || aClass.isTank )
            [allHealingClassSpecs addObject:aClass];
    }];
    return allHealingClassSpecs;
}


@end
