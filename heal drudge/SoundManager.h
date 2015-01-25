//
//  SoundManager.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Ability.h"

@interface SoundManager : NSObject

@property NSObject *audioPlayer;

+ (void)playNoteSound;
+ (void)playDangerSound;
+ (void)playCatastrophicSound;
+ (void)playSoundForAbilityLevel:(AbilityLevel)abilityLevel;

+ (void)playCountdownWithStartIndex:(NSNumber *)startIndex;

@end
