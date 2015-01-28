//
//  SacredShieldAbsorbEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SacredShieldAbsorbEffect.h"

#import "ImageFactory.h"

@implementation SacredShieldAbsorbEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Sacred Shield";
        self.duration = 10;
        self.image = [ImageFactory imageNamed:@"sacred_shield"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

@end
