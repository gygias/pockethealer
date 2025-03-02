//
//  Logging.c
//  heal drudge
//
//  Created by david on 2/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity.h"
#import "Spell.h"
#import "HDClass.h"

static PHLogApprovalBlock sPHLogApprovalBlock;
void PHLog(id source,NSString *format, ...)
{
    if ( ! sPHLogApprovalBlock )
    {
        PHLogSetApprovalBlock(^BOOL(id source) {
#if TARGET_IPHONE_SIMULATOR
            if ( [source isKindOfClass:[Entity class]] )
            {
//                if ( ((Entity *)source).isPlayingPlayer )
//                    return YES;
//                if ( ((Entity *)source).hdClass.isTank )
//                    return YES;
//                if ( ((Entity *)source).hdClass.isHealerClass )
//                    return YES;
            }
            else if ( [source isKindOfClass:[Spell class]] )
            {
//                if ( ((Spell *)source).caster.isPlayingPlayer )
//                    return YES;
//                if ( ((Spell *)source).target.isPlayingPlayer )
//                    return YES;
//                if ( ((Spell *)source).caster.hdClass.isHealerClass )
//                    return YES;
//                if ( ((Spell *)source).target.hdClass.isHealerClass )
//                    return YES;
//                if ( ((Spell *)source).caster.hdClass.isTank )
//                    return YES;
//                if ( ((Spell *)source).target.hdClass.isTank )
//                    return YES;
            }
#endif
            return NO;
        });
    }
    
    if ( ! sPHLogApprovalBlock(source) )
        return;
    
    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"%@",logString);
}

void PHLogSetApprovalBlock(PHLogApprovalBlock block)
{
    sPHLogApprovalBlock = block;
}