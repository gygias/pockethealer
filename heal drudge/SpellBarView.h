//
//  SpellBarView.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class Spell;
@class Entity;

typedef BOOL(^SpellCastAttemptBlock)(Spell *);

@interface SpellBarView : UIView
{
    NSDate *_emphasisReferenceDate;
}

@property (nonatomic,copy) SpellCastAttemptBlock spellCastAttemptHandler;

@property (nonatomic,retain) Entity *player;

@end
