//
//  SpellBarView.h
//  pockethealer
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class Spell;
@class Entity;

typedef BOOL(^SpellCastAttemptBlock)(Spell *);
typedef void(^SpellBarViewDragBegan)(Spell *, CGPoint);
typedef void(^SpellBarViewDragUpdated)(Spell *, CGPoint);
typedef void(^SpellBarViewDragEnded)(Spell *, CGPoint);

@interface SpellBarView : UIView
{
    NSDate *_emphasisReferenceDate;
    NSUInteger rows;
    NSUInteger columns;
    CGRect _lastRect;
}

@property (nonatomic,copy) SpellCastAttemptBlock spellCastAttemptHandler;

@property (nonatomic,retain) Entity *player;

@property Spell *currentDragSpell;
@property Spell *depressedSpell;
@property (nonatomic,copy) SpellBarViewDragBegan dragBeganHandler;
@property (nonatomic,copy) SpellBarViewDragUpdated dragUpdatedHandler;
@property (nonatomic,copy) SpellBarViewDragEnded dragEndedHandler;

- (CGRect)rectForSpell:(Spell *)spell;
- (Spell *)_explanationSpell;
- (CGPoint)_explanationSpellCenter;

@end
