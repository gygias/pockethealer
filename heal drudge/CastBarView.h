//
//  CastBarView.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class Spell;
@class Entity;

@interface CastBarView : UIView
{
    CGRect _lastRect;
    BOOL _refreshCachedValues;
    CGRect _imageRect;
    CGRect _textRect;
    CGRect _remainingTimeRect;
    NSDictionary *_textAttributes;
}

@property Entity *entity;

@end
