//
//  SoundManager.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SoundManager.h"

#import <AVFoundation/AVFoundation.h>

@implementation SoundManager

+ (void)playNoteSound
{
    [self say:@"ding"];
}

+ (void)playDangerSound
{
    [self say:@"beware"];
}

+ (void)playCatastrophicSound;
{
    [self say:@"destruction"];
}

+ (void)playSoundForAbilityLevel:(AbilityLevel)abilityLevel
{
    switch (abilityLevel)
    {
        case NotableAbility:
            [self playNoteSound];
            break;
        case DangerousAbility:
            [self playDangerSound];
            break;
        case CatastrophicAbility:
            [self playCatastrophicSound];
            break;
        default:
            break;
    }
}

+ (void)say:(NSString *)text
{
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [utterance setRate:1.1f];
    [synthesizer speakUtterance:utterance];
}

@end
