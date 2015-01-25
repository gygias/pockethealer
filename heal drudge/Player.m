//
//  Player.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Player.h"
#import "ItemLevelAndStatsConverter.h"
#import "Spell.h"
#import "Encounter.h"
#import "Effect.h"

#define HD_NAME_MIN 3
#define HD_NAME_MAX 12

@implementation Player

@synthesize castingSpell = _castingSpell;

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter
{
    __block NSNumber *effectiveCastTime = nil;
    
    if ( self.castingSpell )
    {
        NSLog(@"%@ cancelled casting %@",self,self.castingSpell);
        _castingSpell = nil;
        _castingSpell.lastCastStartDate = nil;
    }
    
    if ( spell.castTime.doubleValue > 0 )
    {
        NSLog(@"%@ started casting %@",self,spell);
        
        NSMutableArray *modifiers = [NSMutableArray new];
        if ( [self handleSourceOfSpellStart:spell withTarget:target modifiers:modifiers] )
        {
        }
        if ( [target handleTargetOfSpellStart:spell withSource:self modifiers:modifiers] )
        {
        }
        
        _castingSpell = spell;
        NSDate *thisCastStartDate = [NSDate date];
        self.castingSpell.lastCastStartDate = thisCastStartDate;
        
        __block NSNumber *hasteBuff = nil;
        
        [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"considering %@ for %@",obj,spell);
            if ( obj.hasteIncreasePercentage )
            {
                if ( ! hasteBuff || [obj.hasteIncreasePercentage compare:hasteBuff] == NSOrderedDescending )
                    hasteBuff = obj.hasteIncreasePercentage; // oh yeah, we're not using haste at all yet
            }
        }];
        
        if ( hasteBuff )
            NSLog(@"%@'s haste is buffed by %@",self,hasteBuff);
        
        // get base cast time
        effectiveCastTime = [ItemLevelAndStatsConverter castTimeWithBaseCastTime:spell.castTime entity:self hasteBuffPercentage:hasteBuff];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveCastTime.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // blah
            if ( thisCastStartDate != self.castingSpell.lastCastStartDate )
            {
                NSLog(@"%@ was aborted because it is no longer the current spell at dispatch time",spell);
                return;
            }
            [encounter handleSpell:self.castingSpell source:self target:target periodicTick:NO];
            _castingSpell = nil;
            NSLog(@"%@ finished casting %@",self,spell);
            
        });
    }
    else
    {
        NSLog(@"%@ cast %@ (instant)",self,spell);
        [encounter handleSpell:spell source:self target:target periodicTick:NO];
    }
    
    return effectiveCastTime;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@,%@]",self.name,self.currentHealth,self.currentResources];
}

@end
