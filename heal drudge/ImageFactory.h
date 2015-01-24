//
//  ImageFactory.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDClass.h"

@interface ImageFactory : NSObject

+ (UIImage *)questionMark;
+ (UIImage *)imageNamed:(NSString *)vagueName;
+ (UIImage *)imageForClass:(HDClass *)hdClass;
+ (UIImage *)imageForSpec:(HDClass *)hdClass;

@end
