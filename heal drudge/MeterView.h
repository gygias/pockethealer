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
    NoMode = 0,
    HealingDoneMode,
    HealingTakenMode,
    OverhealingMode,
    DamageDoneMode,
    DamageTakenMode
};

typedef void (^MeterViewTouchedBlock)();

@interface MeterView : UIView

@property Encounter *encounter;
@property (nonatomic) MeterMode mode;
@property (nonatomic,copy) MeterViewTouchedBlock touchedHandler;
@property CGRect lastRect;

@end
