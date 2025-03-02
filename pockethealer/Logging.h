//
//  Logging.h
//  pockethealer
//
//  Created by david on 2/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#ifndef __heal_drudge__Logging__
#define __heal_drudge__Logging__

#import <Foundation/Foundation.h>

@class Entity;

typedef BOOL (^PHLogApprovalBlock)(id source);

#ifdef TARGET_IPHONE_SIMULATOR
#define PHLogV NSLog
#else
#define PHLogV PHLog(self,
#endif

void PHLog(id source,NSString *format, ...) NS_FORMAT_FUNCTION(2,3);
void PHLogSetApprovalBlock(PHLogApprovalBlock block);

#endif /* defined(__heal_drudge__Logging__) */
