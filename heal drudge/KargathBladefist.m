//
//  KargathBladefist.m
//  heal drudge
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
    }    
    return self;
}

- (void)beginEncounter:(Encounter *)encounter
{
    [super beginEncounter:encounter];
    
    self.location = CGPointMake(self.roomSize.width / 2, self.roomSize.height / 2);
}

- (NSArray *)abilityNames
{
    return @[@"Attack",@"BladeDance",@"Impale",@"BerserkerRush"];
}

- (UIBezierPath *)roomPathWithRect:(CGRect)rect
{
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,rect.size.width,rect.size.height)];
}

@end
