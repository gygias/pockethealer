//
//  SoundManager.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Ability.h"
#import "Spell.h"
#import "Effect.h"

#define LOW_VOLUME ((float)0.1)
#define MED_VOLUME ((float)0.5)
#define HIGH_VOLUME ((float)1)

@interface SoundManager : NSObject

@property (nonatomic,retain) dispatch_queue_t soundQueue;
@property NSMutableDictionary *audioPlayers;

typedef void(^StartedPlayingSoundBlock)(id sound);

+ (void)playNoteSound;
+ (void)playDangerSound;
+ (void)playCatastrophicSound;
+ (void)playSoundForAbilityLevel:(AbilityLevel)abilityLevel;
+ (void)playSpellFizzle:(Spell *)school;
+ (void)playSpellSound:(Spell *)spell duration:(NSTimeInterval)duration;
+ (void)playSpellHit:(Spell *)spell;
+ (void)playEffectHit:(Effect *)spell;
+ (void)playHitSound:(Entity *)entity;
+ (void)playAggroSound:(Entity *)entity;
+ (void)playDeathSound;

+ (void)playCountdownWithStartIndex:(NSNumber *)startIndex;

@end
