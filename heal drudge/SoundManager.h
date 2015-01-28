//
//  SoundManager.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Ability.h"
#import "Spell.h"

#define LOW_VOLUME ((float)0.1)
#define MED_VOLUME ((float)0.5)
#define HIGH_VOLUME ((float)1)

@interface SoundManager : NSObject

@property (nonatomic,retain) dispatch_queue_t soundQueue;
@property NSMutableArray *audioPlayers;

typedef void(^StartedPlayingSoundBlock)(id sound);

+ (void)playNoteSound;
+ (void)playDangerSound;
+ (void)playCatastrophicSound;
+ (void)playSoundForAbilityLevel:(AbilityLevel)abilityLevel;
+ (void)playSpellFizzle:(SpellSchool)school volume:(float)volume;
+ (void)playSpellSound:(SpellSchool)school level:(NSString *)level volume:(float)volume duration:(NSTimeInterval)duration handler:(StartedPlayingSoundBlock)handler;
+ (void)playSpellHit:(NSString *)hitSoundName volume:(float)volume;
+ (void)playDeathSound;

+ (void)playCountdownWithStartIndex:(NSNumber *)startIndex;

@end
