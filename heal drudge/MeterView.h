//
//  MeterView.h
//  heal drudge
//
//  Created by david on 2/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "Encounter.h"

typedef NS_ENUM(NSUInteger,MeterMode)
{
    HealingDoneMode = 0,
    OverhealingMode,
    DamageDoneMode,
    HealingTakenMode
};

typedef void (^MeterViewTouchedBlock)();

@interface MeterView : UIView

@property Encounter *encounter;
@property MeterMode mode;
@property (nonatomic,copy) MeterViewTouchedBlock touchedHandler;

@end
