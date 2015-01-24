//
//  KargathBladefist.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "KargathBladefist.h"

@implementation KargathBladefist

- (id)init
{
    if ( self = [super init] )
    {
        
    }    
    return self;
}

- (void)beginEncounter:(Encounter *)encounter
{
    [super beginEncounter:encounter];
}

- (NSArray *)abilityNames
{
    return @[@"Attack",@"BladeDance",@"Impale"];
}

@end
