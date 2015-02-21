//
//  Advisor.m
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Advisor.h"

#import "Spell.h"
#import "Event.h"
#import "EventModifier.h"
#import "Encounter.h"

#import "ArchangelSpell.h"

#import "SpeechBubbleViewController.h"

@implementation Advisor

- (void)updateEncounter
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __block SpeechBubbleViewController *vc = nil;
        [self.encounter.player.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
            if ( spell.isEmphasized && self.callback )
            {
                    vc = [self _emphasisForSpell:spell];
                    if ( vc )
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(self.encounter.player,vc); });
                        *stop = YES;
                    }
            }
        }];
        
        if ( vc )
            return;
        
        [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *aPlayer, NSUInteger idx, BOOL *stop) {
            if ( aPlayer.isPlayingPlayer )
                return;
            if ( ! self.didExplainOOM && aPlayer.hdClass.isHealerClass  && aPlayer.currentResourcePercentage.doubleValue < 0.05 )
            {
                self.didExplainOOM = YES;
                vc = [self _oom:aPlayer];
                if ( vc )
                {
                    self.callback(aPlayer,vc);
                    *stop = YES;
                }
            }
            else if ( ! self.didExplainNeedsHealing && aPlayer.currentHealthPercentage.doubleValue < 0.5 )
            {
                self.didExplainNeedsHealing = YES;
                vc = [self _needsHealing:aPlayer];
                if ( vc )
                {
                    self.callback(aPlayer,vc);
                    *stop = YES;
                }
            }
        }];
    
        if ( vc )
            return;
    });
}

- (void)handleSpell:(Spell *)spell event:(Event *)event modifier:(EventModifier *)modifier
{
    if ( ! self.didExplainTank && spell != BeneficialEffect && spell.caster.isEnemy && spell.target.hdClass.isTank )
    {
        self.didExplainTank = YES;
        if ( self.callback )
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(spell.target,[self _tankExplanation]);
            });
    }
}

- (SpeechBubbleViewController *)_emphasisForSpell:(Spell *)spell
{
    SpeechBubbleViewController *vc = nil;
    if ( [spell isKindOfClass:[ArchangelSpell class]] && ! self.didExplainArchangel )
    {
        self.didExplainArchangel = YES;
        vc = [SpeechBubbleViewController speechBubbleViewControllerWithImage:spell.image
                                                                        text:@"You have 5 stacks of Evangelism, use Archangel now to increase healing done by 25%!"];
    }
    
    return vc;
}

- (SpeechBubbleViewController *)_tankExplanation
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:TankRole]
                                                                      text:@"This is a tank. Tanks take most of the damage, so focus on healing them up."];
}

- (SpeechBubbleViewController *)_oom:(Entity *)oomEntity
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:[NSString stringWithFormat:@"%@ is out of mana, help them out by healing more!",oomEntity.name]];
}

- (SpeechBubbleViewController *)_needsHealing:(Entity *)entityInNeedOfHealing
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:[NSString stringWithFormat:@"%@ needs healing, heal them up!",entityInNeedOfHealing.name]];
}

@end
