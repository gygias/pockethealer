//
//  ForbearanceEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ForbearanceEffect.h"

#import "LayOnHandsSpell.h"
#import "ImageFactory.h"

@implementation ForbearanceEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Forbearance";
        self.duration = 60;
        self.image = [ImageFactory imageNamed:@"forbearance"];
        self.drawsInFrame = YES;
        self.effectType = DetrimentalEffect;
    }
    
    return self;
}

- (BOOL)validateSpell:(Spell *)spell asEffectOfSource:(BOOL)asEffectOfSource source:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{    
    if ( self.owner == spell.target &&  ( [spell isKindOfClass:[LayOnHandsSpell class]]
        // || [spell isKindOfClass:[DivineShieldEffect class]]
        // || [spell isKindOfClass:[BlessingOfProtectionEffect class]]
        ) )
    {
        if ( message )
            *message = [NSString stringWithFormat:@"Cannot cast that on target with %@",self.name];
        NSLog(@"%@ WANTS TO LAY ON HANDS BUT CANT DUE TO FORBEARANCE ON %@",source,target);
        return NO;
    }
    
    return YES;
}

@end
