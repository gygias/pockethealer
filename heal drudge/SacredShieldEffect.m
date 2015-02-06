//
//  SacredShieldEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SacredShieldEffect.h"

#import "SacredShieldAbsorbEffect.h"
#import "Entity.h"
#import "ImageFactory.h"

@implementation SacredShieldEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Sacred Shield";
        self.duration = 30;
        self.image = [ImageFactory imageNamed:@"sacred_shield"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
        
        self.periodicTick = @6;
        self.canAffectOneTargetSimultaneously = YES;
    }
    
    return self;
}

- (void)handleTickWithOwner:(Entity *)owner isInitialTick:(BOOL)isInitialTick
{
    [super handleTickWithOwner:owner isInitialTick:isInitialTick];
    
    // apply absorb
    SacredShieldAbsorbEffect *ssa = [SacredShieldAbsorbEffect new];
    double theAbsorb = ( 1 + 1.306 * self.source.spellPower.doubleValue );
    if ( self.source.hdClass.specID == HDRETPALADIN )
        theAbsorb = theAbsorb * 0.7;
    ssa.absorb = @(theAbsorb);
    [owner addStatusEffect:ssa source:owner];
}

@end
