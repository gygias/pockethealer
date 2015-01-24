//
//  State.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Character.h"

@interface State : NSObject

@property Character *character;

// setup
@property BOOL saveGuildToo;

@end
