//
//  Advisor.m
//  pockethealer
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
#import "PlayViewController.h"

#import "ArchangelSpell.h"

#import "SpeechBubbleViewController.h"

@implementation Advisor

- (void)_nextUIExplanation
{
    if ( self.mode == HowToPlayAdvisorManual )
        [self _nextUIExplanationManual];
    else if ( self.mode == HowToPlayAdvisorAuto )
        [self _nextUIExplanationManual];
}

- (void)_nextUIExplanationAuto
{
    
}

- (void)_nextUIExplanationManual
{
    self.isExplainingUI = YES;
    __unsafe_unretained typeof(self) weakSelf = self;
    
    if ( self.currentExplanationState == UIExplanationStart )
    {
        NSLog(@"UIExplanationEnemyAwaitingTouch");
        SpeechBubbleViewController *vc = [self _enemyFrame];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
            return (BOOL)( weakSelf.currentExplanationState != UIExplanationEnemyAwaitingTouch );
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationEnemyAwaitingTouch),vc); });
        self.currentExplanationState = UIExplanationEnemyAwaitingTouch;
        self.advanceExplanationBlock = ^{
            if ( weakSelf.encounter.player.target.isEnemy )
            {
                weakSelf.currentExplanationState = UIExplanationEnemyTouched;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationEnemyTouched )
    {
        NSLog(@"UIExplanationRaidFramesAwaitingTouch");
        SpeechBubbleViewController *vc = [self _raidFrames];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
            return (BOOL)( weakSelf.currentExplanationState != UIExplanationRaidFramesAwaitingTouch );
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationRaidFramesAwaitingTouch),vc); });
        self.currentExplanationState = UIExplanationRaidFramesAwaitingTouch;
        self.advanceExplanationBlock = ^{
            if ( weakSelf.encounter.player.target.isPlayer && ! weakSelf.encounter.player.target.isPlayingPlayer )
            {
                weakSelf.currentExplanationState = UIExplanationRaidFramesTouched;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationRaidFramesTouched )
    {
        NSLog(@"UIExplanationPlayerAndTargetAwaitingPlayer");
        SpeechBubbleViewController *vc = [self _playerInPlayerAndTarget];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
            return (BOOL)( weakSelf.currentExplanationState != UIExplanationPlayerAndTargetAwaitingPlayer );
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationPlayerAndTargetAwaitingPlayer),vc); });
        self.currentExplanationState = UIExplanationPlayerAndTargetAwaitingPlayer;
        self.advanceExplanationBlock = ^{
            if ( weakSelf.encounter.player.target.isPlayingPlayer )
            {
                weakSelf.currentExplanationState = UIExplanationPlayerAndTargetPlayer;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationPlayerAndTargetPlayer )
    {
        NSLog(@"UIExplanationPlayerAndTargetAwaitingTarget");
        SpeechBubbleViewController *vc = [self _targetInPlayerAndTarget];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
            return (BOOL)( weakSelf.currentExplanationState != UIExplanationPlayerAndTargetAwaitingTarget );
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationPlayerAndTargetAwaitingTarget),vc); });
        self.currentExplanationState = UIExplanationPlayerAndTargetAwaitingTarget;
        self.advanceExplanationBlock = ^{
            if ( ! weakSelf.encounter.player.target.isPlayingPlayer ) // XXX
            {
                weakSelf.currentExplanationState = UIExplanationPlayerAndTargetTarget;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationPlayerAndTargetTarget )
    {
        NSLog(@"UIExplanationPlayerAndTargetAwaitingTargetTarget");
        SpeechBubbleViewController *vc = [self _targetTargetInPlayerAndTarget];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
            return (BOOL)( weakSelf.currentExplanationState != UIExplanationPlayerAndTargetAwaitingTargetTarget );
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationPlayerAndTargetAwaitingTargetTarget),vc); });
        self.currentExplanationState = UIExplanationPlayerAndTargetAwaitingTargetTarget;
        Entity *previousTarget = weakSelf.encounter.player.target;
        self.advanceExplanationBlock = ^{
            if ( ! weakSelf.encounter.player.target.isPlayingPlayer && weakSelf.encounter.player.target != previousTarget ) // XXX
            {
                weakSelf.currentExplanationState = UIExplanationPlayerAndTargetTargetTarget;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationPlayerAndTargetTargetTarget )
    {
        NSLog(@"UIExplanationSpellBarAwaitingCastTimeSpell");
        SpeechBubbleViewController *vc = [self _spellBar];
//        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc) {
//            if ( ! self.awaitingCastTimeSpell )
//            {
//                self.currentExplanationState = UIExplanationSpellBarDidCastCastTimeSpell;
//                return YES;
//            }
//            return NO;
//        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationSpellBarAwaitingCastTimeSpell),vc); });
        self.awaitingCastTimeSpell = YES;
        self.currentExplanationState = UIExplanationSpellBarAwaitingCastTimeSpell;
        
        NSDate *cheeseDate = [NSDate date];
        self.advanceExplanationBlock = ^{
            if ( [[NSDate date] timeIntervalSinceDate:cheeseDate] >= AUTO_ADVANCE_DELAY )
            {
                weakSelf.currentExplanationState = UIExplanationSpellBarDidCastCastTimeSpell;
                return YES;
            }
            return NO;
        };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationSpellBarDidCastCastTimeSpell )
//    {
//        NSLog(@"UIExplanationCastBar");
//        SpeechBubbleViewController *vc = [self _castBar];
//        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc){
//            dispatch_async(dispatch_get_main_queue(), ^{[self _nextUIExplanation];});
//            return YES;
//        };
//        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationCastBar),vc); });
//        self.currentExplanationState = UIExplanationCastBar;
//        return;
//    }
//    else if ( self.currentExplanationState == UIExplanationCastBar )
    {
        NSLog(@"UIExplanationMiniMap");
        SpeechBubbleViewController *vc = [self _miniMap];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc){
            dispatch_async(dispatch_get_main_queue(), ^{[self _nextUIExplanation];});
            return YES;
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationMiniMap),vc); });
        self.currentExplanationState = UIExplanationMiniMap;
        self.advanceExplanationBlock = ^{ return YES; };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationMiniMap )
    {
        NSLog(@"UIExplanationMeter");
        SpeechBubbleViewController *vc = [self _meter];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc){
            dispatch_async(dispatch_get_main_queue(), ^{[self _nextUIExplanation];});
            return YES;
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationMeter),vc); });
        self.currentExplanationState = UIExplanationMeter;
        self.advanceExplanationBlock = ^{ return YES; };
        return;
    }
    else if ( self.currentExplanationState == UIExplanationMeter )
    {
        NSLog(@"UIExplanationCommandButton");
        SpeechBubbleViewController *vc = [self _commandButton];
        vc.shouldDismissHandler = ^(SpeechBubbleViewController *vc){
            dispatch_async(dispatch_get_main_queue(), ^{[self _nextUIExplanation];});
            return YES;
        };
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationCommandButton),vc); });
        self.currentExplanationState = UIExplanationCommandButton;
        self.advanceExplanationBlock = ^{ return YES; };
        return;
    }
    else
    {
        NSLog(@"UIExplanationEnd");
        self.currentExplanationState = UIExplanationStateNone;
        dispatch_async(dispatch_get_main_queue(), ^{ self.callback(@(UIExplanationEnd),nil); });
        self.isExplainingUI = NO;
        self.didExplainUI = YES;
        self.mode = NoAdvisor;
    }
}

- (void)updateEncounter
{
    if ( self.mode == NoAdvisor )
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( self.mode == HowToPlayAdvisorManual || self.mode == HowToPlayAdvisorAuto )
        {
            if ( ! self.didExplainUI )
            {
                if ( self.currentExplanationState == UIExplanationStateNone )
                {
                    self.lastAdvanceExplanationDate = [NSDate date];
                    self.currentExplanationState = UIExplanationStart;
                    [self _nextUIExplanation];
                    return;
                }
                else if ( self.advanceExplanationBlock && self.advanceExplanationBlock()
                         && ( [[NSDate date] timeIntervalSinceDate:self.lastAdvanceExplanationDate] >= AUTO_ADVANCE_DELAY ) )
                {
                    self.lastAdvanceExplanationDate = [NSDate date];
                    [self _nextUIExplanation];
                }
            }
            return;
        }
    
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

- (void)handleSpellStart:(Spell *)spell modifiers:(NSArray *)modifiers
{
    if ( self.mode == NoAdvisor )
        return;
}

- (void)handleSpell:(Spell *)spell event:(Event *)event modifier:(EventModifier *)modifier
{
//    if ( self.currentExplanationState == UIExplanationSpellBarAwaitingCastTimeSpell )
//    {
//        if ( spell.caster.isPlayingPlayer && spell.castTime.doubleValue > 0 )
//        {
//            NSLog(@"%@ cast-time spell %@",spell.caster,spell);
//            self.awaitingCastTimeSpell = NO;
//            self.currentExplanationState = UIExplanationSpellBarDidCastCastTimeSpell;
//            [self _nextUIExplanation];
//            return;
//        }
//    }
    
    if ( self.mode == NoAdvisor )
        return;
    if ( self.isExplainingUI )
        return;
    
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

- (SpeechBubbleViewController *)_enemyFrame
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is the enemy your raid is fighting. Target the enemy by tapping here."];
}

- (SpeechBubbleViewController *)_raidFrames
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is your raid team. Target someone in your raid by tapping them here."];
}

- (SpeechBubbleViewController *)_playerInPlayerAndTarget
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is a copy of your own frame. You can also target yourself by touching here."];
}

- (SpeechBubbleViewController *)_targetInPlayerAndTarget
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:[NSString stringWithFormat:@"This is your target. Targeted spells cast now will be directed at %@",self.encounter.player.target.name]];
}

- (SpeechBubbleViewController *)_targetTargetInPlayerAndTarget
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is the target of your target. You can target them yourself by touching here."];
}

- (SpeechBubbleViewController *)_spellBar
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is the spell bar. You can cast spells by touching them. You can also rearrange them by dragging."];
}

- (SpeechBubbleViewController *)_castBar
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This bar shows the spell you are currently casting, and the time it will take to finish casting."];
}

- (SpeechBubbleViewController *)_miniMap
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is the mini map. Your location is indicated by ☺, enemies by ☠, and other raiders by class dots."];
}

- (SpeechBubbleViewController *)_meter
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"This is the meter. It can show how much healing or damage your raid is doing. Try to top the meters!"];
}

- (SpeechBubbleViewController *)_commandButton
{
    return [SpeechBubbleViewController speechBubbleViewControllerWithImage:[ImageFactory imageForRole:HealerRole]
                                                                      text:@"Touch the command button to bark at your raid, telling them to stack, spread out, or pop heroism!"];
}

@end
