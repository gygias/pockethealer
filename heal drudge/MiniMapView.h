//
//  MiniMapView.h
//  heal drudge
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "Encounter.h"

@interface MiniMapView : UIView

@property (nonatomic,retain) Encounter *encounter;

@end
