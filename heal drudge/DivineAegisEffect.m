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

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Divine Aegis";
        self.duration = 15;
        self.image = [ImageFactory imageNamed:@"divine_aegis"];
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)validateSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target message:(NSString *__autoreleasing *)message
{    
    return YES;
}

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target
{
    // if source has glyph of weakened soul
    // ...
}

@end
