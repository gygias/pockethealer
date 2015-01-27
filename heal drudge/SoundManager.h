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

@interface SoundManager : NSObject

@property (nonatomic,retain) dispatch_queue_t soundQueue;
@property NSMutableArray *audioPlayers;

typedef void(^StartedPlayingSoundBlock)(id sound);

+ (void)playNoteSound;
+ (void)playDangerSound;
+ (void)playCatastrophicSound;
+ (void)playSoundForAbilityLevel:(AbilityLevel)abilityLevel;
+ (void)playSpellFizzle:(SpellSchool)school;
+ (void)playSpellSound:(SpellSchool)school level:(NSString *)level duration:(NSTimeInterval)duration handler:(StartedPlayingSoundBlock)handler;
+ (void)playSpellHit:(NSString *)hitSoundName;
+ (void)playDeathSound;

+ (void)playCountdownWithStartIndex:(NSNumber *)startIndex;

@end
