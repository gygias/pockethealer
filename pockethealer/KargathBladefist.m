//
//  KargathBladefist.m
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "KargathBladefist.h"

#import "Raid.h"
#import "ItemLevelAndStatsConverter.h"

@implementation KargathBladefist

- (id)initWithRaid:(Raid *)raid difficulty:(float)difficulty
{
    if ( self = [super initWithRaid:raid difficulty:difficulty] )
    {
        NSNumber *raidAverageDPS = [ItemLevelAndStatsConverter averageDPSOfEntities:raid.players];
        self.stamina = @(( 3 * 60 * raidAverageDPS.doubleValue / 60 ) * ( difficulty + .5 ) );
        self.aggroSoundName = @"kargath_aggro";
        self.hitSoundName = @"kargath_hit";
        self.deathSoundName = @"kargath_death";
        self.roomSize = CGSizeMake(150, 100);
        self.lastRealLocation = CGPointMake(self.roomSize.width / 2, self.roomSize.height / 2);
    }    
    return self;
}

- (void)beginEncounter:(Encounter *)encounter
{
    [super beginEncounter:encounter];    
}

- (NSArray *)abilityNames
{
    return @[@"Attack",@"BladeDance",@"Impale",@"BerserkerRush"];
}

#define RING_OVAL_INSET 2

- (UIBezierPath *)roomPathWithRect:(CGRect)rect
{
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(RING_OVAL_INSET,
                                                             RING_OVAL_INSET,
                                                             rect.size.width - 2 * RING_OVAL_INSET,
                                                             rect.size.height - 2 * RING_OVAL_INSET)];
}

- (UIBezierPath *)tankAreaWithRect:(CGRect)rect
{
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.location.x + 5,
                                                             self.location.y,
                                                             5,
                                                             5)];
}

- (UIBezierPath *)meleeAreaWithRect:(CGRect)rect
{
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.location.x - 5,
                                                             self.location.y,
                                                             5,
                                                             10)];
}

#define RANGE_OVAL_INSET 4

- (UIBezierPath *)rangeAreaWithRect:(CGRect)rect
{
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(RANGE_OVAL_INSET,
                                                             RANGE_OVAL_INSET,
                                                             rect.size.width - 2 * RANGE_OVAL_INSET,
                                                             rect.size.height - 2 * RANGE_OVAL_INSET)];
}

@end
