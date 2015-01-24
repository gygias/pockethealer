//
//  ModelBase.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelBase : NSObject

// for subclasses derived from JSON requests, denotes whether or not they are 'complete'
// individual character info requests don't return full guild info, merely name and realm (from which we can derive the rest)
// while guild member lists don't return full member info.
// in some places it is most convenient to work with these 'incomplete' transient objects, and we have
// a way of remembering they are so.
@property BOOL isComplete;

@end
