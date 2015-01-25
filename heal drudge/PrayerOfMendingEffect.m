//
//  PrayerOfMendingEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PrayerOfMendingEffect.h"

#import "ImageFactory.h"

@implementation PrayerOfMendingEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Prayer of Mending";
        self.duration = 30;
        self.currentStacks = @5;
        self.image = [ImageFactory imageNamed:@"prayer_of_mending"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

@end
