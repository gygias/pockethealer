//
//  DirectoryGuesser.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "DirectoryGuesser.h"

@implementation DirectoryGuesser

NSMutableDictionary *sGiantFuckingDictionary = nil;

+ (void)initialize
{
    if ( self == [DirectoryGuesser class] )
    {
        sGiantFuckingDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[self _fuckingStoragePath]];
        if ( ! sGiantFuckingDictionary )
            sGiantFuckingDictionary = [NSMutableDictionary dictionary];
    }
}

+ (BOOL)guessWhereToPutGuild:(Guild *)guild
{
    if ( ! guild.isComplete )
        PHLogV(@"i can't store incomplete guilds ya idjit");
    return YES;
}

+ (BOOL)guessWhereToPutCharacter:(Entity *)character
{
    if ( ! character.isComplete )
        PHLogV(@"i can't store incomplete characters ya idjit");
    return YES;
}

+ (NSString *)_fuckingStoragePath
{
    NSString *guessPath = [[self _applicationDataDirectory] path];
    NSString *storePath = [guessPath stringByAppendingPathComponent:@"com.combobulatedsoftware.healdrudge.plist"];
    return storePath;
}

+ (NSURL*)_applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}


@end
