//
//  Entity+ProtPaladin.h
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity.h"

@class Event;

@interface Entity (ProtPaladin)

- (void)handleProtPallyIncomingDamageEvent:(Event *)damageEvent;

@end
