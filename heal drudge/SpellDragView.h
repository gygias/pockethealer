//
//  SpellDragView.h
//  heal drudge
//
//  Created by david on 2/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpellDragView : UIView

typedef void (^PlayViewAuxiliaryDrawBlock)();
@property (nonatomic,copy) PlayViewAuxiliaryDrawBlock auxiliaryDrawHandler;

@end
