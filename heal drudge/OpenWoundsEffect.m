//
//  ImpaleEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "OpenWoundsEffect.h"

#import "Impale.h"
#import "ImageFactory.h"

@implementation OpenWoundsEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Open Wounds";
        self.tooltip = @"Kargath tosses you off his bladefist, leaving you with open wounds that increases the damage from Kargath's next Impale by 100% for 1.2 min.";
        self.duration = 1.2 * 60.0;
        self.image = [ImageFactory imageNamed:@"recuperate"];
        self.drawsInFrame = YES;
        self.isEmphasized = YES;
        self.tauntAtStacks = @1;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    BOOL addedModifiers = NO;
    
    if ( [spell isKindOfClass:[Impale class]] )
    {
        NSUInteger effectiveStacks = self.currentStacks.unsignedIntegerValue;
        if ( [spell.lastCastStartDate isEqual:self.ignoreCastsAtDate] )
            effectiveStacks--;
        NSLog(@"EFFECTIVE STACKS %u vs %u",effectiveStacks,self.currentStacks.unsignedIntegerValue);
        if ( effectiveStacks > 0 )
        {
            EventModifier *mod = [EventModifier new];
            mod.source = self;
            mod.damageIncreasePercentage = @( 1 * effectiveStacks );
            [modifiers addObject:mod];
            addedModifiers = YES;
        }
    }
    
    return addedModifiers;
}

@end
