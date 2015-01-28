//
//  DivineAegisEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DivineAegisEffect.h"

#import "ImageFactory.h"

@implementation DivineAegisEffect

+ (NSNumber *)absorbWithExistingAbsorb:(NSNumber *)existingAbsorb healing:(NSNumber *)healing masteryRating:(NSNumber *)masteryRating sourceMaxHealth:(NSNumber *)sourceMaxHealth
{
    NSNumber *totalAbsorb = @(( existingAbsorb.doubleValue + healing.doubleValue));
    double halfSourceHealth = sourceMaxHealth.doubleValue * 0.5; // TODO this maths is probably wrong, apply mastery bonus?
    if ( totalAbsorb.doubleValue > halfSourceHealth )
        totalAbsorb = @(halfSourceHealth);
    return totalAbsorb;
}

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Divine Aegis";
        self.duration = 15;
        self.image = [ImageFactory imageNamed:@"divine_aegis"];
        self.effectType = BeneficialEffect;
        self.absorb = @0;
        
        self.drawsInFrame = YES;
    }
    
    return self;
}

@end
