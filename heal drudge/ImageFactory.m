//
//  ImageFactory.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ImageFactory.h"

@implementation ImageFactory

NSMutableDictionary *sImageFactoryCache = nil;

+ (void)initialize
{
    if ( self == [ImageFactory class] )
        sImageFactoryCache = [NSMutableDictionary new];
}

+ (UIImage *)questionMark
{
    NSString *name = @"question_mark";
    UIImage *questionMark = [sImageFactoryCache objectForKey:name];
    if ( ! questionMark )
        [UIImage imageNamed:name];
    if ( questionMark )
        [sImageFactoryCache setObject:questionMark forKey:name];
    return questionMark;
}

+ (UIImage *)imageNamed:(NSString *)vagueName
{
    UIImage *theImage = [sImageFactoryCache objectForKey:vagueName];
    if ( ! theImage )
    {
        NSArray *extensionsInOrderOfPreference = @[@"png",@"jpg",@"jpeg",@"gif"];
        for ( NSString *extension in extensionsInOrderOfPreference )
        {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:vagueName ofType:extension];
            if ( imagePath )
            {
                theImage = [UIImage imageWithContentsOfFile:imagePath];
                if ( theImage )
                {
                    [sImageFactoryCache setObject:theImage forKey:vagueName];
                    break;
                }
            }
        }
    }
    
    if ( ! theImage )
        theImage = [self questionMark];
    
    return theImage;
}

+ (UIImage *)imageForClass:(HDClass *)hdClass
{
    if ( hdClass.classID == HDPRIEST )
        return [self imageNamed:@"priest"];
    else if ( hdClass.classID == HDPALADIN )
        return [self imageNamed:@"paladin"];
    else if ( hdClass.classID == HDSHAMAN )
        return [self imageNamed:@"shaman"];
    else if ( hdClass.classID == HDDRUID )
        return [self imageNamed:@"druid"];
    else if ( hdClass.classID == HDMONK )
        return [self imageNamed:@"monk"];
    else if ( hdClass.classID == HDROGUE )
        return [self imageNamed:@"rogue"];
    else if ( hdClass.classID == HDHUNTER )
        return [self imageNamed:@"hunter"];
    else if ( hdClass.classID == HDWARRIOR )
        return [self imageNamed:@"warrior"];
    else if ( hdClass.classID == HDWARLOCK )
        return [self imageNamed:@"warlock"];
    else if ( hdClass.classID == HDMAGE )
        return [self imageNamed:@"mage"];
    else if ( hdClass.classID == HDDEATHKNIGHT )
        return [self imageNamed:@"deathknight"];
    return [self imageNamed:@"question_mark"];
}

+ (UIImage *)imageForSpec:(HDClass *)hdClass
{
    if ( hdClass.specID == HDDISCPRIEST )
        return [self imageNamed:@"power_word_shield"];
    else if ( hdClass.specID == HDHOLYPRIEST )
        return [self imageNamed:@"guardian_spirit"];
    else if ( hdClass.specID == HDSHADOWPRIEST )
        return [self imageNamed:@"shadow_word_pain"];
    
    else if ( hdClass.specID == HDHOLYPALADIN )
        return [self imageNamed:@"divine_light"];
    else if ( hdClass.specID == HDPROTPALADIN )
        return [self imageNamed:@"avengers_shield"];
    else if ( hdClass.specID == HDRETPALADIN )
        return [self imageNamed:@"retribution_aura"];
    
    else if ( hdClass.specID == HDRESTOSHAMAN )
        return [self imageNamed:@"resto_shaman"];
    else if ( hdClass.specID == HDELESHAMAN )
        return [self imageNamed:@"lightning_bolt"];
    else if ( hdClass.specID == HDENHANCESHAMAN )
        return [self imageNamed:@"lightning_shield"];
    
    else if ( hdClass.specID == HDRESTODRUID )
        return [self imageNamed:@"resto_druid"];
    else if ( hdClass.specID == HDFERALDRUID )
        return [self imageNamed:@"feral_druid"];
    else if ( hdClass.specID == HDBALANCEDRUID )
        return [self imageNamed:@"moonfire"];
    
    else if ( hdClass.specID == HDMISTWEAVERMONK )
        return [self imageNamed:@"mistweaver"];
    else if ( hdClass.specID == HDBREWMASTERMONK )
        return [self imageNamed:@"brewmaster"];
    else if ( hdClass.specID == HDWINDWALKERMONK )
        return [self imageNamed:@"windwalker"];
    
    else if ( hdClass.specID == HDCOMBATROGUE )
        return [self imageNamed:@"eviscerate"];
    else if ( hdClass.specID == HDSUBTLETYROGUE )
        return [self imageNamed:@"stealth"];
    else if ( hdClass.specID == HDASSASSINATIONROGUE )
        return [self imageNamed:@"backstab"];
    
    else if ( hdClass.specID == HDBEASTMASTERHUNTER )
        return [self imageNamed:@"beast_mastery"];
    else if ( hdClass.specID == HDSURVIVALHUNTER )
        return [self imageNamed:@"survival"];
    else if ( hdClass.specID == HDMARKSMANHUNTER )
        return [self imageNamed:@"marksmanship"];
    
    else if ( hdClass.specID == HDPROTWARRIOR )
        return [self imageNamed:@"protection_warrior"];
    else if ( hdClass.specID == HDARMSWARRIOR )
        return [self imageNamed:@"arms"];
    else if ( hdClass.specID == HDFURYWARRIOR )
        return [self imageNamed:@"fury"];
    
    else if ( hdClass.specID == HDDESTROWARLOCK )
        return [self imageNamed:@"rain_of_fire"];
    else if ( hdClass.specID == HDDEMONOLOGYWARLOCK )
        return [self imageNamed:@"demonology"];
    else if ( hdClass.specID == HDAFFLICTIONWARLOCK )
        return [self imageNamed:@"affliction"];
    
    else if ( hdClass.specID == HDFIREMAGE )
        return [self imageNamed:@"fire"];
    else if ( hdClass.specID == HDFROSTMAGE )
        return [self imageNamed:@"frost_mage"];
    else if ( hdClass.specID == HDARCANEMAGE )
        return [self imageNamed:@"arcane"];
    
    else if ( hdClass.specID == HDUNHOLYDK )
        return [self imageNamed:@"unholy"];
    else if ( hdClass.specID == HDBLOODDK )
        return [self imageNamed:@"blood"];
    else if ( hdClass.specID == HDFROSTDK )
        return [self imageNamed:@"frost"];
    
    return [self questionMark];
}

+ (UIImage *)imageForRole:(const NSString *)roleString
{
    if ( [roleString isEqualToString:(NSString *)HealerRole] )
        return [self imageNamed:@"healer_role"];
    else if ( [roleString isEqualToString:(NSString *)TankRole] )
        return [self imageNamed:@"tank_role"];
    else if ( [roleString isEqualToString:(NSString *)DPSRole] )
        return [self imageNamed:@"dps_role"];
    return [self questionMark];
}

@end
