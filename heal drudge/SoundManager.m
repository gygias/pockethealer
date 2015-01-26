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

static SoundManager *sSoundManager;

+ (void)initialize
{
    if ( [self class] == [SoundManager class] )
    {
        sSoundManager = [SoundManager new];
    }
}

+ (void)playNoteSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"belltollnightelf" ofType:@"wav"];
    [self playFileWithPath:path];
    //[self say:@"ding"];
}

+ (void)playDangerSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UR_Algalon_BHole01" ofType:@"wav"];
    [self playFileWithPath:path];
    //[self say:@"bee wear"];
}

+ (void)playCatastrophicSound;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"KILJAEDEN02" ofType:@"wav"];
    [self playFileWithPath:path];
    //[self say:@"destruction"];
}

+ (void)playFileWithPath:(NSString *)path
{
    [self playFileWithPath:path duration:0];
}

+ (void)playFileWithPath:(NSString *)path duration:(NSTimeInterval)duration
{
    NSLog(@"%@ is trying to play %@",self,path);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        if ( path )
        {
            NSURL * url = [NSURL fileURLWithPath:path];
            AVAudioPlayer *sound = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                        error:&error] ;
            // http://stackoverflow.com/questions/14951535/how-to-play-wav-file
            // When audioPlayer gets out of scope it gets deallocated and then sound playing will be stopped. Add a property to the class and it will remain for the duration of the object life-time. –  Jens Schwarzer Sep 25 '13
            sSoundManager.audioPlayer = sound;
            if (! sound) {
                NSLog(@"Sound named '%@' had error %@", path, [error localizedDescription]);
            } else {
                if ( [sound play] )
                {
                    NSLog(@"playing %@",path);
                    
                    if ( duration > 0 )
                    {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [sound stop];
                        });
                    }
                }
                else
                    NSLog(@"failed playing %@",path);
            }
        }
    });
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

+ (void)playSpellFizzle:(SpellSchool)school
{
    NSString *fileName = nil;
    switch(school)
    {
        case FireSchool:
            fileName = @"spell_fizzle_fire";
            break;
        case FrostSchool:
            fileName = @"spell_fizzle_frost";
            break;
        case NatureSchool:
            fileName = @"spell_fizzle_nature";
            break;
        case ShadowSchool:
            fileName = @"spell_fizzle_shadow";
            break;
        case HolySchool:
            fileName = @"spell_fizzle_holy";
            break;
        default:
            break;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    if ( fileName )
        [self playFileWithPath:filePath];
}

+ (void)playSpellSound:(SpellSchool)school level:(NSString *)level duration:(NSTimeInterval)duration
{
    NSString *fileNameBase = nil;
    switch(school)
    {
        case HolySchool:
            fileNameBase = @"precast_holy";
            break;
        default:
            break;
            
    }
    
    if ( fileNameBase && level )
    {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@",fileNameBase,level];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
        [self playFileWithPath:filePath duration:duration];
    }
}

+ (void)say:(NSString *)text
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];
        [synthesizer speakUtterance:utterance];
    });
}

+ (void)playCountdownWithStartIndex:(NSNumber *)startIndex
{
    //NSUInteger currentIndex = startIndex.unsignedIntegerValue;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"index"] = startIndex;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(_lol:) userInfo:dictionary repeats:YES];
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
//    dispatch_async(globalQueue, ^{
//        __block NSUInteger currentIndex = startIndex.unsignedIntegerValue;
//        NSNumber *maxCountdownIndex = @10;
//        if ( currentIndex > maxCountdownIndex.unsignedIntegerValue )
//        {
//            NSLog(@"%@ can only count down from %@",self,maxCountdownIndex);
//            return;
//        }
//        NSLog(@"%@ is counting down from %@",self,startIndex);
//        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
//        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
//        dispatch_source_set_event_handler(timer, ^{
//            NSString *fileName = [NSString stringWithFormat:@"%lu",currentIndex];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
//            [self playFileWithPath:filePath];
//            currentIndex--;
//        });
//        dispatch_resume(timer);
//    });
}

+ (void)_lol:(id)lol
{
    NSMutableDictionary *userInfo = [(NSTimer *)lol userInfo];
    NSNumber *currentIndex = userInfo[@"index"];
    if ( currentIndex.integerValue == 1 )
        [(NSTimer *)lol invalidate];
    else
        userInfo[@"index"] = @( currentIndex.integerValue - 1 );
    NSString *fileName = [NSString stringWithFormat:@"%@",currentIndex];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    [self playFileWithPath:filePath];
}

@end
