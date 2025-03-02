//
//  DivineAegisEffect.h
//  pockethealer
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Effect.h"

@interface DivineAegisEffect : Effect

+ (NSNumber *)absorbWithExistingAbsorb:(NSNumber *)existingAbsorb healing:(NSNumber *)healing masteryRating:(NSNumber *)masteryRating sourceMaxHealth:(NSNumber *)sourceMaxHealth;

@end
