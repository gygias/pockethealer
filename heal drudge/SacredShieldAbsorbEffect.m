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
        self.duration = 6; // TODO not sure this number is right, no 'unique' attribute replacing pre-existing absorb
        self.image = [ImageFactory imageNamed:@"sacred_shield"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
        
        self.hitSoundName = @"power_word_shield_hit";
    }
    
    return self;
}

@end
