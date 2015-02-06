//
//  EvangelismEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "EvangelismEffect.h"

#import "Entity.h"
#import "ArchangelSpell.h"

#import "ImageFactory.h"

@implementation EvangelismEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Evangelism";
        self.duration = 20;
        self.maxStacks = @5;
        self.effectType = BeneficialEffect;
        self.image = [ImageFactory imageNamed:@"evangelism"];
    }
    
    return self;
}

- (void)addStack
{
    [super addStack];
    
    if ( self.currentStacks.integerValue == self.maxStacks.integerValue )
    {
        // TODO this feels like spaghetti
        ArchangelSpell *aa = (ArchangelSpell *)[self.source spellWithClass:[ArchangelSpell class]];
        [self.source emphasizeSpell:aa duration:self.duration];
    }
}

@end
