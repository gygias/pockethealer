//
//  Entity+AI.h
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity.h"

#import "Spell.h"

@interface Entity (AI)

- (AISpellPriority)currentSpellPriorities:(NSDictionary **)outTargetMap;
- (BOOL)castHighestPrioritySpell;

@end
