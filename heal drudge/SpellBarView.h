//
//  SpellBarView.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Spell;
@class Player;

typedef BOOL(^SpellCastAttemptBlock)(Spell *);

@interface SpellBarView : UIView

@property (nonatomic,copy) SpellCastAttemptBlock spellCastAttemptHandler;

@property (nonatomic,retain) Player *player;
@property (nonatomic,retain) NSArray *spells;

@end
