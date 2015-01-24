//
//  DirectoryGuesser.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Guild.h"
#import "Character.h"

@interface DirectoryGuesser : NSObject

+ (BOOL)guessWhereToPutGuild:(Guild *)guild;
+ (BOOL)guessWhereToPutCharacter:(Character *)character;

@end
