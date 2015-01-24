//
//  Raid.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Raid.h"
#import "Player.h"
#import "HDClass.h"

#import "ItemLevelAndStatsConverter.h"

@implementation Raid

+ (Raid *)randomRaid
{
    NSString *namesPath = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"];
    NSArray *names = [NSArray arrayWithContentsOfFile:namesPath];
    
    NSMutableArray *players = [NSMutableArray array];
    NSUInteger randomSize = [names count] - arc4random() % 10;
    NSUInteger idx = 0;
    for ( ; idx < randomSize; idx++ )
    {
        Player *aPlayer = [Player new];
        Character *aCharacter = [Character new];
        aCharacter.name = names[idx];
        aCharacter.averageItemLevelEquipped = @630;
        aCharacter.hdClass = [HDClass randomClass];
        
        [ItemLevelAndStatsConverter assignStatsToCharacter:aCharacter
                           basedOnAverageEquippedItemLevel:@630];
        
        aPlayer.character = aCharacter;
        
        NSLog(@"added %@ (%@)",aPlayer,aCharacter);
        
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

+ (Raid *)randomRaidWithGygiasTheDiscPriest:(Player **)outGygias
{
    Raid *raid = [self randomRaid];
    
    Character *gygiasChar = [Character new];
    gygiasChar.name = @"Gygias";
    gygiasChar.averageItemLevelEquipped = @630;
    gygiasChar.hdClass = [HDClass discPriest];
    
    [ItemLevelAndStatsConverter assignStatsToCharacter:gygiasChar
                       basedOnAverageEquippedItemLevel:@630];
    
    Player *gygias = [Player new];
    gygias.character = gygiasChar;
    
    NSMutableArray *raidCopy = raid.players.mutableCopy;
    __block NSInteger gygiasIdx = -1;
    [raidCopy enumerateObjectsUsingBlock:^(Player *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj.character.name compare:gygias.character.name options:NSCaseInsensitiveSearch] == NSOrderedSame )
        {
            gygiasIdx = idx;
            *stop = YES;
        }
    }];
    
    if ( gygiasIdx >= 0 )
    {
        NSLog(@"removing %@",[raidCopy objectAtIndex:gygiasIdx]);
        [raidCopy removeObjectAtIndex:gygiasIdx];
    }
    else
        gygiasIdx = 0;
    
    NSLog(@"adding %@",gygias);
    [raidCopy insertObject:gygias atIndex:gygiasIdx];
    if ( raid.players.count >= 20 )
        [raidCopy removeObjectAtIndex: ( gygiasIdx + 1 % raid.players.count )];
    raid.players = raidCopy;
    
    NSLog(@"%@",raid.players);
    
    if ( outGygias )
        *outGygias = gygias;
    
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

- (NSArray *)meleePlayers
{
    return [self _playersWithRole:DPSRole range:MeleeRange];
}

- (NSArray *)rangePlayers
{
    return [self _playersWithRole:DPSRole range:RangeRange];
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
    [self.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player *player = (Player *)obj;
        if ( [player.character.hdClass hasRole:role] &&
                ( ( range == AnyRange )
                    || ( player.character.hdClass.isRanged && ( range == RangeRange ) )
                    || ( ! player.character.hdClass.isRanged && ( range == MeleeRange ) )
             )
            )
        {
            if ( ! filteredPlayers ) filteredPlayers = [NSMutableArray new];
            [filteredPlayers addObject:player];
        }
    }];
    
    return filteredPlayers;
}

@end
