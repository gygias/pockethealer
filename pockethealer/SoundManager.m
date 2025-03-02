//
//  SoundManager.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <AVFoundation/AVFoundation.h>

@implementation SoundManager

static SoundManager *sSoundManager;

+ (void)initialize
{
    if ( [self class] == [SoundManager class] )
    {
        sSoundManager = [SoundManager new];
        sSoundManager.soundQueue = dispatch_queue_create("SoundQueue", 0);
    }
}

+ (NSString *)_pathForResourceNamed:(NSString *)name
{
    if ( ! name )
        return nil;
    // for whatever reason, if name is empty or nil this returns the 'last path encountered for type'
    return [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
}

+ (void)playNoteSound
{
    NSString *path = [self _pathForResourceNamed:@"belltollnightelf"];
    [self playFileWithPath:path volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
    //[self say:@"ding"];
}

+ (void)playDangerSound
{
    NSString *path = [self _pathForResourceNamed:@"UR_Algalon_BHole01"];
    [self playFileWithPath:path volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
    //[self say:@"bee wear"];
}

+ (void)playCatastrophicSound;
{
    NSString *path = [self _pathForResourceNamed:@"KILJAEDEN02"];
    [self playFileWithPath:path volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
    //[self say:@"destruction"];
}

+ (void)playSpellHit:(Spell *)spell
{
    NSString *filePath = [self _pathForResourceNamed:spell.hitSoundName];
    BOOL emphasized = spell.caster.isPlayingPlayer || spell.caster.isEnemy;
    float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
    [self playFileWithPath:filePath volume:volume duration:0 throttled:!emphasized handler:NULL];
}

+ (void)playEffectHit:(Effect *)effect
{
    // TODO if this gets called with nil, "1.wav" plays. (???)
    NSString *filePath = [self _pathForResourceNamed:effect.hitSoundName];
    BOOL emphasized = effect.source.isPlayingPlayer || effect.source.isEnemy;
    float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
    [self playFileWithPath:filePath volume:volume duration:0 throttled:!emphasized handler:NULL];
}

+ (void)playFileWithPath:(NSString *)path volume:(float)volume duration:(NSTimeInterval)duration throttled:(BOOL)throttled handler:(StartedPlayingSoundBlock)handler
{
    if ( ! path )
        return;
#define SOUND_ENABLED
#ifndef SOUND_ENABLED
    return;
#endif
    dispatch_async(sSoundManager.soundQueue, ^{
        
        NSDictionary *existingSoundEvent = [sSoundManager.audioPlayers objectForKey:path];
        if ( throttled && [existingSoundEvent[@"throttled"] boolValue] )
        {
            //PHLogV(@"%@ is throttled",path);
            return;
        }
        
        NSError *error = nil;
        NSURL * url = [NSURL fileURLWithPath:path];
        AVAudioPlayer *sound = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                    error:&error];
        sound.volume = volume;
        
        if ( sound )
        {
            // http://stackoverflow.com/questions/14951535/how-to-play-wav-file
            // When audioPlayer gets out of scope it gets deallocated and then sound playing will be stopped. Add a property to the class and it will remain for the duration of the object life-time. –  Jens Schwarzer Sep 25 '13
            if ( ! sSoundManager.audioPlayers )
                sSoundManager.audioPlayers = [NSMutableDictionary new];
            NSDictionary *soundEvent = @{ @"date" : [NSDate date],
                                          @"throttled" : [NSNumber numberWithBool:throttled],
                                          @"sound" : sound };
            [sSoundManager.audioPlayers setObject:soundEvent forKey:path];
            NSTimeInterval effectiveDuration = duration ? duration : sound.duration;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveDuration * 2 * NSEC_PER_SEC)), sSoundManager.soundQueue, ^{
                [sSoundManager.audioPlayers removeObjectForKey:path];
            });
            
            if ( [sound play] )
            {
                //PHLogV(@"playing %@",path);
                
                if ( handler )
                    handler(sound);
                
                if ( duration > 0 )
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), sSoundManager.soundQueue, ^{
                        [sound stop];
                    });
                }
            }
            else
                PHLogV(@"failed playing %@",path);
        }
        else
            PHLogV(@"failed to initialize sound from %@",url);
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

+ (void)playSpellFizzle:(Spell *)spell
{
    NSString *fileName = nil;
    switch(spell.school)
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
    
    NSString *filePath = [self _pathForResourceNamed:fileName];
    if ( fileName )
    {
        BOOL emphasized = spell.caster.isPlayingPlayer || spell.caster.isEnemy;
        float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
        [self playFileWithPath:filePath volume:volume duration:0 throttled:!emphasized handler:NULL];
    }
}

+ (void)playHitSound:(Entity *)entity
{
    if ( entity.hitSoundName )
    {
        NSString *filePath = [self _pathForResourceNamed:entity.hitSoundName];
        if ( filePath )
        {
            BOOL emphasized = entity.isPlayingPlayer || entity.isEnemy;
            float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
            [self playFileWithPath:filePath volume:volume duration:0 throttled:YES handler:NULL];
        }
    }
}

+ (void)playAggroSound:(Entity *)entity
{
    if ( entity.aggroSoundName )
    {
        NSString *filePath = [self _pathForResourceNamed:entity.aggroSoundName];
        if ( filePath )
        {
            BOOL emphasized = entity.isPlayingPlayer || entity.isEnemy;
            float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
            [self playFileWithPath:filePath volume:volume duration:0 throttled:!emphasized handler:NULL];
        }
    }
}

+ (void)playSpellSound:(Spell *)spell duration:(NSTimeInterval)duration
{
    NSString *fileNameBase = nil;
    switch(spell.school)
    {
        case HolySchool:
            fileNameBase = @"precast_holy";
            break;
        case ShadowSchool:
            fileNameBase = @"precast_shadow";
        default:
            break;
            
    }
    
    if ( fileNameBase && spell.level )
    {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@",fileNameBase,spell.level];
        NSString *filePath = [self _pathForResourceNamed:fileName];
        BOOL emphasized = spell.caster.isPlayingPlayer || spell.caster.isEnemy;
        float volume = emphasized ? HIGH_VOLUME : LOW_VOLUME;
        [self playFileWithPath:filePath volume:volume duration:duration throttled:!emphasized handler:NULL];
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
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_nsTimerCountdown:) userInfo:dictionary repeats:YES];
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
//    dispatch_async(globalQueue, ^{
//        __block NSUInteger currentIndex = startIndex.unsignedIntegerValue;
//        NSNumber *maxCountdownIndex = @10;
//        if ( currentIndex > maxCountdownIndex.unsignedIntegerValue )
//        {
//            PHLogV(@"%@ can only count down from %@",self,maxCountdownIndex);
//            return;
//        }
//        PHLogV(@"%@ is counting down from %@",self,startIndex);
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

+ (void)playDeathSound
{
    NSString *filePath = [self _pathForResourceNamed:@"abandon_quest"];
    [self playFileWithPath:filePath volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
}

+ (void)_nsTimerCountdown:(id)nsTimer
{
    NSMutableDictionary *userInfo = [(NSTimer *)nsTimer userInfo];
    NSNumber *currentIndex = userInfo[@"index"];
    if ( currentIndex.integerValue == 0 )
    {
        [(NSTimer *)nsTimer invalidate];
        return;
    }
    else
        userInfo[@"index"] = @( currentIndex.integerValue - 1 );
    NSString *fileName = [NSString stringWithFormat:@"%@",currentIndex];
    NSString *filePath = [self _pathForResourceNamed:fileName];
    [self playFileWithPath:filePath volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
}

+ (void)playSpellQueueSound
{
    NSString *filePath = [self _pathForResourceNamed:@"spell_queue"];
    [self playFileWithPath:filePath volume:HIGH_VOLUME duration:0 throttled:NO handler:NULL];
}

@end
