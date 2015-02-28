//
//  Conveniences.h
//  heal drudge
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#ifndef heal_drudge_Conveniences_h
#define heal_drudge_Conveniences_h

NSString * PointString(CGPoint point);
NSString * RectString(CGRect rect);

#define REAL_TIME_DRAWING_INTERVAL 0.033
#define REAL_TIME_DRAWING_LEEWAY 0.01

typedef NS_OPTIONS(NSInteger,PlayViewDrawMode)
{
    NoDrawMode = 0,
    StateDrawMode =         1 << 0,
    PositionalDrawMode =    1 << 1,
    FutureEventDrawMode =   1 << 2,
    AllDrawModes = StateDrawMode | PositionalDrawMode
};

#endif
