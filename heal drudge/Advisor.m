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
    [self.encounter.player.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        if ( spell.isEmphasized && self.callback )
        {
            __block SpeechBubbleViewController *vc = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                vc = [self _emphasisForSpell:spell];
                if ( vc )
                    self.callback(self.encounter.player,vc);
            });
            if ( vc )
                *stop = YES;
        }
    }];
}

- (void)handleSpell:(Spell *)spell event:(Event *)event modifier:(EventModifier *)modifier
{
    if ( ! self.didExplainTank && spell != BeneficialEffect && spell.caster.isEnemy && spell.target.hdClass.isTank )
    {
        NSLog(@"something is damaging the tank!");
        self.didExplainTank = YES;
        if ( self.callback )
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(spell.target,[self _tankExplanation]);
            });
    }
}

- (SpeechBubbleViewController *)_speechBubble
{
    SpeechBubbleViewController *vc = [[SpeechBubbleViewController alloc] initWithNibName:@"SpeechBubbleView" bundle:nil];
    [vc loadView];
    return vc;
}

- (SpeechBubbleViewController *)_emphasisForSpell:(Spell *)spell
{
    SpeechBubbleViewController *vc = nil;
    if ( [spell isKindOfClass:[ArchangelSpell class]] && ! self.didExplainArchangel )
    {
        self.didExplainArchangel = YES;
        vc = [self _speechBubble];
        vc.imageView.image = spell.image;
        vc.textLabel.text = @"You have 5 stacks of Evangelism, use Archangel now to increase healing done by 25%!";
    }
    
    return vc;
}

- (SpeechBubbleViewController *)_tankExplanation
{
    SpeechBubbleViewController *vc = [self _speechBubble];
    vc.textLabel.text = @"This is a tank. Tanks take most of the damage, so focus on healing them up.";
    vc.imageView.image = [ImageFactory imageForRole:TankRole];
    return vc;
    //return [[[NSBundle mainBundle] loadNibNamed:@"TankExplanationView" owner:tankExplanationView options:nil] firstObject];
}

@end
