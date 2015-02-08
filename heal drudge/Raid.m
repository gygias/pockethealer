//
//  Raid.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Raid.h"
#import "Entity.h"
#import "HDClass.h"

#import "ItemLevelAndStatsConverter.h"

@implementation Raid

+ (Raid *)randomRaid
{
    return [self randomRaidWithSize:10 tanks:2 healerRatio:0.2];
}

+ (Raid *)randomRaidWithSize:(NSUInteger)size tanks:(NSUInteger)tanks healerRatio:(float)healerRatio
{
    NSString *namesPath = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"];
    NSArray *names = [NSArray arrayWithContentsOfFile:namesPath];
    
    NSMutableArray *players = [NSMutableArray array];
    NSUInteger randomSize = [names count] - arc4random() % 10;
    // XXX
    randomSize = size;
    NSUInteger nHealers = healerRatio * randomSize;
    NSUInteger idx = 0;
    for ( ; idx < randomSize; idx++ )
    {
        Entity *aPlayer = [Entity new];
        aPlayer.isPlayer = YES;
        aPlayer.name = names[idx];
        aPlayer.averageItemLevelEquipped = @630;
        aPlayer.hdClass = [HDClass randomClass];
        
        if ( idx < tanks )
            aPlayer.hdClass = [HDClass randomTankClass];
        else if ( ( idx >= tanks ) && ( idx - tanks < nHealers ) )
            aPlayer.hdClass = [HDClass randomHealerClass];
        else
            aPlayer.hdClass = [HDClass randomDPSClass];
        
        [ItemLevelAndStatsConverter assignStatsToEntity:aPlayer
                        basedOnAverageEquippedItemLevel:@630];
        [aPlayer initializeSpells];
        
        PHLogV(@"added %@",aPlayer);
        
        // cheap ass randomize
        if ( idx == 0 )
            [players addObject:aPlayer];
        else
            [players insertObject:aPlayer atIndex:(arc4random() % 2) == 1 ? 0 : [players count]];
        
    }
    
    Raid *aRaid = [Raid new];
    aRaid.players = players;
    
    return aRaid;
}

+ (Raid *)randomRaidWithStandardDistribution
{
    return [self randomRaidWithSize:10 tanks:2 healerRatio:.2];
}

+ (Raid *)randomRaidWithGygiasTheDiscPriestAndSlyTheProtPaladin:(Entity **)outGygias :(Entity **)outSlyeri :(Entity **)outLireal size:(NSUInteger)size
{
    NSUInteger nTanks = 0;
    NSUInteger nForced = (outGygias?1:0) + (outSlyeri?1:0) + (outLireal?1:0);
    if ( size > 5 )
    {
        nTanks = outSlyeri?1:2;
    }
    Raid *raid = [self randomRaidWithSize:size - nForced tanks:nTanks healerRatio:0];
    
    Entity *gygias = nil;
    if ( outGygias )
    {
        gygias = [Entity new];
        gygias.isPlayer = YES;
        gygias.name = @"Gygias";
        gygias.hdClass = [HDClass discPriest];
        NSNumber *gygiasIlvl = @670;
        [ItemLevelAndStatsConverter assignStatsToEntity:gygias
                        basedOnAverageEquippedItemLevel:gygiasIlvl];
        [gygias initializeSpells];
        *outGygias = gygias;
    }
    
    Entity *slyeri = nil;
    if ( outSlyeri )
    {
        slyeri = [Entity new];
        slyeri.isPlayer = YES;
        slyeri.name = @"Slyeri";
        slyeri.hdClass = [HDClass protPaladin];
        NSNumber *slyIlvl = @670;
        [ItemLevelAndStatsConverter assignStatsToEntity:slyeri
                        basedOnAverageEquippedItemLevel:slyIlvl];
        [slyeri initializeSpells];
        *outSlyeri = slyeri;
    }
    
    Entity *lireal = nil;
    if ( outLireal )
    {
        lireal = [Entity new];
        lireal.isPlayer = YES;
        lireal.name = @"Lireal";
        lireal.hdClass = [HDClass holyPaladin];
        NSNumber *lirealIlvl = @670;
        [ItemLevelAndStatsConverter assignStatsToEntity:lireal
                        basedOnAverageEquippedItemLevel:lirealIlvl];
        [lireal initializeSpells];
        *outLireal = lireal;
    }
    
    NSMutableArray *raidCopy = raid.players.mutableCopy;
    __block NSInteger gygiasIdx = -1;
    __block NSInteger slyIdx = -1;
    __block NSInteger lirealIdx = -1;
    __block NSInteger someHealerIdx = -1;
    [raidCopy enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
        if ( gygias && [obj.name compare:gygias.name options:NSCaseInsensitiveSearch] == NSOrderedSame )
            gygiasIdx = idx;
        else if ( obj.hdClass.isHealerClass )
            someHealerIdx = idx;
        else if ( slyeri && [obj.name compare:slyeri.name options:NSCaseInsensitiveSearch] == NSOrderedSame )
            slyIdx = idx;
        else if ( lireal && [obj.name compare:lireal.name options:NSCaseInsensitiveSearch] == NSOrderedSame )
            lirealIdx = idx;
    }];
    
    if ( slyeri )
    {
        if ( slyIdx >= 0 )
        {
            PHLogV(@"removing %@",[raidCopy objectAtIndex:slyIdx]);
            [raidCopy removeObjectAtIndex:slyIdx];
        }
        slyIdx = raidCopy.count;
        PHLogV(@"adding %@",slyeri);
        [raidCopy insertObject:slyeri atIndex:slyIdx];
    }
    
    if ( gygias )
    {
        if ( gygiasIdx >= 0 || someHealerIdx >= 0 )
        {
            NSInteger removeIndex = gygiasIdx >= 0 ? gygiasIdx : someHealerIdx;
            PHLogV(@"removing %@",[raidCopy objectAtIndex:removeIndex]);
            [raidCopy removeObjectAtIndex:removeIndex];
        }
        gygiasIdx = raidCopy.count;
        PHLogV(@"adding %@",gygias);
        [raidCopy insertObject:gygias atIndex:gygiasIdx];
    }
    
    if ( lireal )
    {
        if ( lirealIdx >= 0 )
        {
            PHLogV(@"removing %@",[raidCopy objectAtIndex:lirealIdx]);
            [raidCopy removeObjectAtIndex:lirealIdx];
        }
        lirealIdx = raidCopy.count;
        PHLogV(@"adding %@",lireal);
        [raidCopy insertObject:lireal atIndex:lirealIdx];
    }
    
    //if ( raid.players.count >= 20 )
    //    [raidCopy removeObjectAtIndex: ( ( gygiasIdx >= 0 ? gygiasIdx : someHealerIdx )+ 1 % raid.players.count )];
    
    raid.players = raidCopy;
    
    PHLogV(@"%@",raid.players);
    
    return raid;
}

typedef NS_ENUM(NSInteger, EntityRange) {
    AnyRange            = 0,
    MeleeRange          = 1,
    RangeRange          = 2
};

- (NSArray *)tankPlayers
{
    return [self _playersWithRole:TankRole range:MeleeRange];
}

- (NSArray *)nonTankPlayers
{
    NSMutableArray *nonTankPlayers = [NSMutableArray array];
    NSArray *healers = [self healers];
    if ( healers )
        [nonTankPlayers addObjectsFromArray:healers];
    NSArray *dpsPlayers = [self dpsPlayers];
    if ( dpsPlayers )
        [nonTankPlayers addObjectsFromArray:dpsPlayers];
    return nonTankPlayers;
}

- (NSArray *)meleePlayers
{
    return [self _playersWithRole:DPSRole range:MeleeRange];
}

- (NSArray *)rangePlayers
{
    NSArray *rangeDPS = [self _playersWithRole:DPSRole range:RangeRange];
    NSArray *healers = [self healers];
    NSMutableArray *combined = [NSMutableArray new]; // TODO inconsistent with other methods returning nil if no players
    if ( rangeDPS )
        [combined addObjectsFromArray:rangeDPS];
    if ( healers )
        [combined addObjectsFromArray:healers];
    return combined;
}

- (NSArray *)healers
{
    return [self _playersWithRole:HealerRole range:AnyRange];
}

- (NSArray *)dpsPlayers
{
    return [self _playersWithRole:DPSRole range:AnyRange];
}

- (NSArray *)_playersWithRole:(const NSString *)role range:(EntityRange)range
{
    __block NSMutableArray *filteredPlayers = nil;
    [self.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        if ( [player.hdClass hasRole:role] &&
                ( ( range == AnyRange )
                    || ( player.hdClass.isRanged && ( range == RangeRange ) )
                    || ( ! player.hdClass.isRanged && ( range == MeleeRange ) )
             )
            )
        {
            if ( ! filteredPlayers ) filteredPlayers = [NSMutableArray new];
            [filteredPlayers addObject:player];
        }
    }];
    
    return filteredPlayers;
}

- (NSArray *)partyForEntity:(Entity *)entity includingEntity:(BOOL)includingEntity
{
    NSUInteger idx = [self.players indexOfObject:entity];
    if ( idx == NSNotFound )
    {
        PHLogV(@"error: %@ not found in raid",entity);
        return nil;
    }
    
    NSUInteger partySize = 5;
    NSUInteger partyNumber = idx / partySize;
    NSMutableArray *players = [NSMutableArray new];
    NSUInteger partyIdx = 0;
    for( ; partyIdx < partySize && ( partyNumber * partySize + partyIdx ) < self.players.count; partyIdx++ )
    {
        Entity *aPartyPlayer = self.players[partyNumber * partySize + partyIdx];
        if ( ! includingEntity && entity == aPartyPlayer )
            continue;
        [players addObject:aPartyPlayer];
    }
    
    return players;
}

@end
