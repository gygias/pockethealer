//
//  PowerWordShieldEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PowerWordShieldEffect.h"

#import "ImageFactory.h"

@implementation PowerWordShieldEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Power Word: Shield";
        self.duration = 15;
        self.image = [ImageFactory imageNamed:@"power_word_shield"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

@end
