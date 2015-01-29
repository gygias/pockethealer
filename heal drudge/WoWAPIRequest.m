//
//  WoWAPIRequest.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "WoWAPIRequest.h"
#import "HDClass.h"
#import "Guild.h"

#define kURLBase "http://%@.battle.net/api/wow"
#define kRealmStatusSuffix "%@/realm/status"
#define kGuildMembersSuffix "%@/guild/%@/%@?fields=members"
#define kCharacterInfoSuffix "%@/character/%@/%@?fields=guild,items,stats,talents,titles"

#define kCharacterThumbnailBase "http://%@.battle.net/static-render/%@"

@implementation WoWAPIRequest

- (void)sendRequestWithCompletionHandler:(void (^)(BOOL, id))handler
{
    NSURL *url = [self _url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSLog(@"sending %@",url);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    BOOL okay = ( error == nil );
    
    id responseObject = nil;
    if ( data )
    {
        if ( ! self.isCharacterThumbnailRequest )
            responseObject = [WoWAPIRequest _recursivelyDeserializedJSONObjectWithData:data error:&error];
        else
            responseObject = [UIImage imageWithData:data];
    }
    else
    {
        NSLog(@"nil data result from NSURLConnection");
        okay = NO;
    }
    
    if ( [responseObject isKindOfClass:[NSDictionary class]] )
    {
        if ( [responseObject[@"status"] isEqualToString:@"nok"] )
        {
            okay = NO;
            NSLog(@"request failed: %@",responseObject[@"reason"]);
            responseObject = nil;
        }
    }
    
    handler( okay, responseObject );
}

- (NSURL *)_url
{
    NSString *formattedURLString = nil;
    if ( self.isRealmStatusRequest )
    {
        if ( ! self.realmStatusCountry )
            [NSException raise:@"WoWAPIRequestException" format:@"%@ needs a country",[self class]];
        formattedURLString = [NSString stringWithFormat:@kURLBase,self.realmStatusCountry];
    }
    else
    {
        if ( ! self.realm.country )
            [NSException raise:@"WoWAPIRequestException" format:@"%@ needs a country",[self class]];
        
        if ( self.isCharacterThumbnailRequest )
            formattedURLString = [NSString stringWithFormat:@kCharacterThumbnailBase,self.realm.country,self.realm.country]; // XXX wonder if these are in fact both 'location'
        else
            formattedURLString = [NSString stringWithFormat:@kURLBase,self.realm.country];
    }
    
    if ( self.isRealmStatusRequest )
    {
        formattedURLString = [NSString stringWithFormat:@kRealmStatusSuffix,formattedURLString];
    }
    else if ( self.isGuildMemberListRequest )
    {
        if ( ! self.realm.normalizedName || ! self.guildName )
            [NSException raise:@"WoWAPIRequestException" format:@"%@ needs a normalized realm name and guild name",[self class]];
        NSString *urlReadyGuildName = [WoWAPIRequest _urlReadyString:self.guildName];
        formattedURLString = [NSString stringWithFormat:@kGuildMembersSuffix,formattedURLString,self.realm.normalizedName,urlReadyGuildName];
    }
    else if ( self.isCharacterInfoRequest )
    {
        if ( ! self.realm.normalizedName || ! self.characterName )
            [NSException raise:@"WoWAPIRequestException" format:@"%@ needs a normalized realm name and character name",[self class]];
        NSString *urlReadyCharacterName = [WoWAPIRequest _urlReadyString:self.characterName];
        formattedURLString = [NSString stringWithFormat:@kCharacterInfoSuffix,formattedURLString,self.realm.normalizedName,urlReadyCharacterName];
    }
    else if ( self.isCharacterThumbnailRequest )
    {
        if ( ! self.characterThumbnailURLSuffix )
            [NSException raise:@"WoWAPIRequestException" format:@"%@ needs a thumbnail url suffix",[self class]];
        formattedURLString = [NSString stringWithFormat:@"%@/%@",formattedURLString,self.characterThumbnailURLSuffix];
    }
    NSURL *url = [NSURL URLWithString:formattedURLString];
    return url;
}

+ (NSString *)_urlReadyString:(NSString *)guildName
{
    // http://stackoverflow.com/questions/8088473/url-encode-an-nsstring
    // Unfortunately, stringByAddingPercentEscapesUsingEncoding doesn't always work 100%. It encodes non-URL characters but leaves the reserved characters (like slash / and ampersand &) alone. Apparently this is a bug that Apple is aware of, but since they have not fixed it yet, I have been using this category to url-encode a string:
    // Oh no!
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)guildName,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8 ));
    return encodedString;
}

+ (NSArray *)realmsFromRealmStatusResponse:(id)response country:(const NSString *)country
{
    NSMutableArray *realms = [NSMutableArray array];
    for ( NSDictionary *realmDict in response[@"realms"] )
    {
        WoWRealm *realm = [WoWRealm realmWithWoWAPIDictionary:realmDict country:country];
        if ( realm )
            [realms addObject:realm];
    }
    
    return realms;
}

/*+ (NSArray *)characterNamesFromGuildListResponse:(id)response
{
    NSMutableArray *characterNames = [NSMutableArray array];
    for ( NSDictionary *characterDictWrapper in response[@"members"] )
    {
        NSDictionary *characterDict = characterDictWrapper[@"character"]; // XXX what's this indirection?
        NSString *characterName = characterDict[@"name"];
        if ( characterName )
        {
            //http://stackoverflow.com/questions/2099349/using-objective-c-cocoa-to-unescape-unicode-characters-ie-u1234
//            NSString* esc1 = [characterName stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
//            NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//            NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
//            NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
//            NSString* unesc = [NSPropertyListSerialization propertyListWithData:data
//                                                                        options:NSPropertyListImmutable
//                                                                         format:NULL
//                                                                          error:NULL];
//            assert([unesc isKindOfClass:[NSString class]]);
//            NSLog(@"Output = %@", unesc);
//            if ( [characterName rangeOfString:@"tara"].location != NSNotFound )
//                NSLog(@"lol %@",characterName);
//            //characterName = [characterName stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
//            NSString *convertedString = [characterName mutableCopy];
//            
//            CFStringRef transform = CFSTR("Any-Hex/Java");
//            CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
            [characterNames addObject:characterName]; // it's just the -description printout, stupid!
        }
    }
    
    return characterNames;
}*/

+ (NSUInteger)averageItemLevelFromCharacterItemsResponse:(id)response
{
    return 0;
}

+ (UIImage *)imageFromCharacterThumbnailResponse:(id)response
{
    return nil;
}

/*2015-01-21 16:23:03.721 heal drudge[14236:1689842] {
 achievementPoints = 13185;
 battlegroup = Ruin;
 calcClass = X;
 class = 5;
 gender = 1;
 guild =     {
 achievementPoints = 800;
 battlegroup = Ruin;
 emblem =         {
 backgroundColor = ffb1002e;
 border = 5;
 borderColor = fff9cc30;
 icon = 38;
 iconColor = ffdfa55a;
 };
 members = 172;
 name = Knightfall;
 realm = "Zul'jin";
 };
 items =     {
 averageItemLevel = 670;
 averageItemLevelEquipped = 668;
 back =         {
 armor = 58;
 bonusLists =             (
 566
 );
 context = "raid-heroic";
 icon = "inv_cape_draenorraid_d_01leather_druid";
 id = 119347;
 itemLevel = 670;
 name = "Gill's Glorious Windcloak";
 quality = 4;
 stats =             (
 {
 amount = 96;
 stat = 49;
 },
 {
 amount = 136;
 stat = 5;
 },
 {
 amount = 82;
 stat = 6;
 },
 {
 amount = 204;
 stat = 7;
 }
 );
 tooltipParams =             {
 enchant = 5312;
 };
 };
 chest =         {
 armor = 105;
 bonusLists =             (
 );
 context = "raid-normal";
 icon = "inv_cloth_raidwarlock_o_01robe";
 id = 113655;
 itemLevel = 655;
 name = "Robes of Necrotic Whispers";
 quality = 4;
 stats =             (
 {
 amount = 113;
 stat = 59;
 },
 {
 amount = 211;
 stat = 5;
 },
 {
 amount = 157;
 stat = 36;
 },
 {
 amount = 316;
 stat = 7;
 }
 );
 tooltipParams =             {
 transmogItem = 94058;
 };
 };
 feet =         {
 armor = 83;
 bonusLists =             (
 561,
 566
 );
 context = "raid-heroic";
 icon = "inv_cloth_raidwarlock_o_01boots";
 id = 113840;
 itemLevel = 676;
 name = "Destablized Sandals";
 quality = 4;
 stats =             (
 {
 amount = 106;
 stat = 49;
 },
 {
 amount = 192;
 stat = 5;
 },
 {
 amount = 141;
 stat = 36;
 },
 {
 amount = 289;
 stat = 7;
 }
 );
 tooltipParams =             {
 };
 };
 finger1 =         {
 armor = 0;
 bonusLists =             (
 567
 );
 context = "raid-mythic";
 icon = "inv_ringwod_d3_4";
 id = 113604;
 itemLevel = 685;
 name = "Kargath's Last Link";
 quality = 4;
 stats =             (
 {
 amount = 112;
 stat = 32;
 },
 {
 amount = 92;
 stat = 49;
 },
 {
 amount = 157;
 stat = 5;
 },
 {
 amount = 235;
 stat = 7;
 }
 );
 tooltipParams =             {
 enchant = 5326;
 };
 };
 finger2 =         {
 armor = 0;
 bonusLists =             (
 );
 context = vendor;
 icon = "inv_misc_6oring_purplelv2";
 id = 118296;
 itemLevel = 680;
 name = "Timeless Solium Band of the Archmage";
 quality = 4;
 stats =             (
 {
 amount = 78;
 stat = 40;
 },
 {
 amount = 113;
 stat = 49;
 },
 {
 amount = 150;
 stat = 5;
 },
 {
 amount = 225;
 stat = 7;
 }
 );
 tooltipParams =             {
 enchant = 5326;
 };
 };
 hands =         {
 armor = 73;
 bonusLists =             (
 566
 );
 context = "raid-heroic";
 icon = "inv_cloth_raidwarlock_o_01gloves";
 id = 113610;
 itemLevel = 670;
 name = "Meatmonger's Gory Grips";
 quality = 4;
 stats =             (
 {
 amount = 98;
 stat = 59;
 },
 {
 amount = 135;
 stat = 32;
 },
 {
 amount = 182;
 stat = 5;
 },
 {
 amount = 273;
 stat = 7;
 }
 );
 tooltipParams =             {
 };
 };
 head =         {
 armor = 99;
 bonusLists =             (
 561,
 566
 );
 context = "raid-heroic";
 icon = "inv_helm_cloth_raidpriest_o_01";
 id = 113596;
 itemLevel = 676;
 name = "Vilebreath Mask";
 quality = 4;
 stats =             (
 {
 amount = 186;
 stat = 59;
 },
 {
 amount = 146;
 stat = 49;
 },
 {
 amount = 257;
 stat = 5;
 },
 {
 amount = 385;
 stat = 7;
 }
 );
 tooltipParams =             {
 };
 };
 legs =         {
 armor = 102;
 bonusLists =             (
 566
 );
 context = "raid-heroic";
 icon = "inv_pant_cloth_raidpriest_o_01";
 id = 113828;
 itemLevel = 670;
 name = "Sea-Cursed Leggings";
 quality = 4;
 stats =             (
 {
 amount = 127;
 stat = 59;
 },
 {
 amount = 242;
 stat = 5;
 },
 {
 amount = 182;
 stat = 36;
 },
 {
 amount = 364;
 stat = 7;
 }
 );
 tooltipParams =             {
 };
 };
 mainHand =         {
 armor = 0;
 bonusLists =             (
 );
 context = "raid-normal";
 icon = "inv_mace_1h_draenorraid_d_03";
 id = 113607;
 itemLevel = 655;
 name = "Butcher's Terrible Tenderizer";
 quality = 4;
 stats =             (
 {
 amount = 51;
 stat = 40;
 },
 {
 amount = 66;
 stat = 49;
 },
 {
 amount = 90;
 stat = 5;
 },
 {
 amount = 136;
 stat = 7;
 },
 {
 amount = 1209;
 stat = 45;
 }
 );
 tooltipParams =             {
 enchant = 5330;
 transmogItem = 865;
 };
 weaponInfo =             {
 damage =                 {
 exactMax = 440;
 exactMin = 236;
 max = 440;
 min = 236;
 };
 dps = "146.95653";
 weaponSpeed = "2.3";
 };
 };
 neck =         {
 armor = 0;
 bonusLists =             (
 566
 );
 context = "raid-heroic";
 icon = "inv_6_0raid_necklace_3b";
 id = 113833;
 itemLevel = 670;
 name = "Odyssian Choker";
 quality = 4;
 stats =             (
 {
 amount = 89;
 stat = 59;
 },
 {
 amount = 92;
 stat = 32;
 },
 {
 amount = 136;
 stat = 5;
 },
 {
 amount = 204;
 stat = 7;
 }
 );
 tooltipParams =             {
 enchant = 5319;
 };
 };
 offHand =         {
 armor = 0;
 bonusLists =             (
 561,
 566
 );
 context = "raid-heroic";
 icon = "inv_offhand_1h_draenorraid_d_02";
 id = 113592;
 itemLevel = 676;
 name = "Bileslinger's Censer";
 quality = 4;
 stats =             (
 {
 amount = 103;
 stat = 32;
 },
 {
 amount = 145;
 stat = 5;
 },
 {
 amount = 85;
 stat = 36;
 },
 {
 amount = 217;
 stat = 7;
 }
 );
 tooltipParams =             {
 transmogItem = 7608;
 };
 };
 shirt =         {
 armor = 0;
 bonusLists =             (
 );
 context = "";
 icon = "inv_shirt_black_01";
 id = 3427;
 itemLevel = 1;
 name = "Stylish Black Shirt";
 quality = 1;
 stats =             (
 );
 tooltipParams =             {
 };
 };
 shoulder =         {
 armor = 82;
 bonusLists =             (
 560
 );
 context = "raid-normal";
 icon = "inv_shoulder_cloth_raidmage_o_01";
 id = 113609;
 itemLevel = 661;
 name = "Slaughterhouse Spaulders";
 quality = 4;
 stats =             (
 {
 amount = 95;
 stat = 59;
 },
 {
 amount = 121;
 stat = 49;
 },
 {
 amount = 167;
 stat = 5;
 },
 {
 amount = 251;
 stat = 7;
 }
 );
 tooltipParams =             {
 transmogItem = 24611;
 };
 };
 trinket1 =         {
 armor = 0;
 bonusLists =             (
 );
 context = "raid-normal";
 icon = "inv_misc_trinket6oog_2heads2";
 id = 113842;
 itemLevel = 655;
 name = "Emblem of Caustic Healing";
 quality = 4;
 stats =             (
 {
 amount = 201;
 stat = 6;
 }
 );
 tooltipParams =             {
 };
 };
 trinket2 =         {
 armor = 0;
 bonusLists =             (
 566
 );
 context = "raid-heroic";
 icon = "inv_misc_trinket6oog_isoceles1";
 id = 113835;
 itemLevel = 670;
 name = "Shards of Nothing";
 quality = 4;
 stats =             (
 {
 amount = 231;
 stat = 5;
 }
 );
 tooltipParams =             {
 };
 };
 waist =         {
 armor = 65;
 bonusLists =             (
 564,
 566
 );
 context = "raid-heroic";
 icon = "inv_belt_cloth_raidpriest_o_01";
 id = 113656;
 itemLevel = 670;
 name = "Girdle of the Infected Mind";
 quality = 4;
 stats =             (
 {
 amount = 133;
 stat = 32;
 },
 {
 amount = 101;
 stat = 40;
 },
 {
 amount = 182;
 stat = 5;
 },
 {
 amount = 273;
 stat = 7;
 }
 );
 tooltipParams =             {
 gem0 = 115805;
 transmogItem = 94059;
 };
 };
 wrist =         {
 armor = 47;
 bonusLists =             (
 );
 context = vendor;
 icon = "inv_bracer_cloth_pvpmage_o_01";
 id = 111099;
 itemLevel = 660;
 name = "Primal Gladiator's Cuffs of Prowess";
 quality = 4;
 stats =             (
 {
 amount = 77;
 stat = 49;
 },
 {
 amount = 89;
 stat = 32;
 },
 {
 amount = 124;
 stat = 5;
 },
 {
 amount = 186;
 stat = 7;
 }
 );
 tooltipParams =             {
 };
 };
 };
 lastModified = 1421807394000;
 level = 100;
 name = Iliss;
 race = 5;
 realm = "Zul'jin";
 stats =     {
 agi = 1065;
 armor = 714;
 attackPower = 0;
 avoidanceRating = 0;
 avoidanceRatingBonus = 0;
 block = 0;
 blockRating = 0;
 bonusArmor = 0;
 crit = "11.336364";
 critRating = 697;
 dodge = 3;
 dodgeRating = 0;
 haste = "6.277779";
 hasteRating = 565;
 hasteRatingPercent = "6.277778";
 health = 266880;
 int = 3857;
 leech = 0;
 leechRating = 0;
 leechRatingBonus = 0;
 mainHandDmgMax = 448;
 mainHandDmgMin = 240;
 mainHandDps = "158.95564";
 mainHandSpeed = "2.164";
 mana5 = 8022;
 mana5Combat = 5611;
 mastery = "29.192728";
 masteryRating = 1127;
 multistrike = "10.727273";
 multistrikeRating = 708;
 multistrikeRatingBonus = "10.727273";
 offHandDmgMax = 0;
 offHandDmgMin = 0;
 offHandDps = 0;
 offHandSpeed = "1.882";
 parry = 0;
 parryRating = 0;
 power = 160000;
 powerType = mana;
 rangedAttackPower = 0;
 rangedDmgMax = "-1";
 rangedDmgMin = "-1";
 rangedDps = "-1";
 rangedSpeed = "-1";
 speedRating = 0;
 speedRatingBonus = 0;
 spellCrit = "11.336364";
 spellCritRating = 697;
 spellPen = 0;
 spellPower = 5066;
 spr = 1170;
 sta = 4448;
 str = 842;
 versatility = 230;
 versatilityDamageDoneBonus = "1.769231";
 versatilityDamageTakenBonus = "0.884615";
 versatilityHealingDoneBonus = "1.769231";
 };
 talents =     (
 {
 calcGlyph = enWH;
 calcSpec = a;
 calcTalent = 0011010;
 glyphs =             {
 major =                 (
 {
 glyph = 262;
 icon = "spell_holy_ashestoashes";
 item = 42407;
 name = "Glyph of Weakened Soul";
 },
 {
 glyph = 710;
 icon = "spell_holy_penance";
 item = 0;
 name = "Glyph of Penance";
 },
 {
 glyph = 261;
 icon = "spell_holy_searinglight";
 item = 0;
 name = "Glyph of Holy Fire";
 }
 );
 minor =                 (
 {
 glyph = 1048;
 icon = "spell_holy_surgeoflight";
 item = 87276;
 name = "Glyph of Holy Resurrection";
 }
 );
 };
 selected = 1;
 spec =             {
 backgroundImage = "bg-priest-discipline";
 description = "Uses magic to shield allies from taking damage as well as heal their wounds.";
 icon = "spell_holy_powerwordshield";
 name = Discipline;
 order = 0;
 role = HEALING;
 };
 talents =             (
 {
 column = 0;
 spell =                     {
 castTime = "2.5 sec cast";
 description = "Shields the target with a protective ward, absorbing 22,539 damage within 20 sec.";
 icon = "ability_priest_clarityofwill";
 id = 152118;
 name = "Clarity of Will";
 powerCost = "3.15% of base mana";
 range = "40 yd range";
 };
 tier = 6;
 },
 {
 column = 0;
 spell =                     {
 castTime = Passive;
 description = "Your Power Word: Shield and Leap of Faith also increase your target's movement speed by 60% for 4 sec.";
 icon = "spell_holy_symbolofhope";
 id = 64129;
 name = "Body and Soul";
 };
 tier = 1;
 },
 {
 column = 0;
 spell =                     {
 castTime = Instant;
 cooldown = "2 min cooldown";
 description = "Heals the caster for 22% of maximum health.";
 icon = "spell_holy_testoffaith";
 id = 19236;
 name = "Desperate Prayer";
 };
 tier = 0;
 },
 {
 column = 1;
 spell =                     {
 castTime = Instant;
 cooldown = "1 min cooldown";
 description = "Creates a Mindbender to attack the target. Caster receives 0.75% mana when the Mindbender attacks. Lasts 15 sec.\n\n\n\nReplaces Shadowfiend.";
 icon = "spell_shadow_soulleech_3";
 id = 123040;
 name = Mindbender;
 range = "40 yd range";
 };
 tier = 2;
 },
 {
 column = 0;
 spell =                     {
 castTime = Passive;
 description = "After healing a target below 35% health, you deal 15% increased damage and healing for 10 sec.";
 icon = "spell_shadow_mindtwisting";
 id = 109142;
 name = "Twist of Fate";
 };
 tier = 4;
 },
 {
 column = 1;
 spell =                     {
 castTime = Instant;
 cooldown = "15 sec cooldown";
 description = "Fire a Divine Star forward 24 yds, healing allies in its path for 1,957. After reaching its destination, the Divine Star returns to you, healing allies in its path again.";
 icon = "spell_priest_divinestar";
 id = 110744;
 name = "Divine Star";
 powerCost = "2% of base mana";
 range = "30 yd range";
 };
 tier = 5;
 },
 {
 column = 1;
 spell =                     {
 castTime = Instant;
 cooldown = "45 sec cooldown";
 description = "The caster lets out a psychic scream, causing 5 enemies within 8 yards to flee, disorienting them for 8 sec.  Damage caused may interrupt the effect.";
 icon = "spell_shadow_psychicscream";
 id = 8122;
 name = "Psychic Scream";
 powerCost = "3% of base mana";
 };
 tier = 3;
 }
 );
 },
 {
 calcGlyph = gcRH;
 calcSpec = Z;
 calcTalent = 0010011;
 glyphs =             {
 major =                 (
 {
 glyph = 266;
 icon = "spell_holy_renew";
 item = 0;
 name = "Glyph of Renew";
 },
 {
 glyph = 258;
 icon = "spell_holy_summonlightwell";
 item = 42403;
 name = "Glyph of Deep Wells";
 },
 {
 glyph = 271;
 icon = "spell_holy_prayerofmendingtga";
 item = 42417;
 name = "Glyph of Prayer of Mending";
 }
 );
 minor =                 (
 {
 glyph = 1048;
 icon = "spell_holy_surgeoflight";
 item = 87276;
 name = "Glyph of Holy Resurrection";
 }
 );
 };
 spec =             {
 backgroundImage = "bg-priest-holy";
 description = "A versatile healer who can reverse damage on individuals or groups and even heal from beyond the grave.";
 icon = "spell_holy_guardianspirit";
 name = Holy;
 order = 1;
 role = HEALING;
 };
 talents =             (
 {
 column = 0;
 spell =                     {
 castTime = Passive;
 description = "Your Power Word: Shield and Leap of Faith also increase your target's movement speed by 60% for 4 sec.";
 icon = "spell_holy_symbolofhope";
 id = 64129;
 name = "Body and Soul";
 };
 tier = 1;
 },
 {
 column = 0;
 spell =                     {
 castTime = Instant;
 cooldown = "2 min cooldown";
 description = "Heals the caster for 22% of maximum health.";
 icon = "spell_holy_testoffaith";
 id = 19236;
 name = "Desperate Prayer";
 };
 tier = 0;
 },
 {
 column = 1;
 spell =                     {
 castTime = Instant;
 cooldown = "15 sec cooldown";
 description = "Fire a Divine Star forward 24 yds, healing allies in its path for 1,957. After reaching its destination, the Divine Star returns to you, healing allies in its path again.";
 icon = "spell_priest_divinestar";
 id = 110744;
 name = "Divine Star";
 powerCost = "2% of base mana";
 range = "30 yd range";
 };
 tier = 5;
 },
 {
 column = 0;
 spell =                     {
 castTime = Instant;
 cooldown = "30 sec cooldown";
 description = "Summons shadowy tendrils, rooting up to 5 enemy targets within 8 yards for 20 sec or until the tendril is killed.";
 icon = "spell_priest_voidtendrils";
 id = 108920;
 name = "Void Tendrils";
 powerCost = "1% of base mana";
 };
 tier = 3;
 },
 {
 column = 0;
 spell =                     {
 castTime = Passive;
 description = "After healing a target below 35% health, you deal 15% increased damage and healing for 10 sec.";
 icon = "spell_shadow_mindtwisting";
 id = 109142;
 name = "Twist of Fate";
 };
 tier = 4;
 },
 {
 column = 1;
 spell =                     {
 castTime = Instant;
 cooldown = "1 min cooldown";
 description = "Creates a Mindbender to attack the target. Caster receives 0.75% mana when the Mindbender attacks. Lasts 15 sec.\n\n\n\nReplaces Shadowfiend.";
 icon = "spell_shadow_soulleech_3";
 id = 123040;
 name = Mindbender;
 range = "40 yd range";
 };
 tier = 2;
 },
 {
 column = 1;
 spell =                     {
 castTime = Passive;
 description = "Your healing and shielding spell casts grant you a stack of Word of Mending. When you gain 10 stacks of Word of Mending, your next targeted healing or shielding spell also casts a Prayer of Mending at them.";
 icon = "ability_priest_wordsofmeaning";
 id = 152117;
 name = "Words of Mending";
 };
 tier = 6;
 }
 );
 }
 );
 thumbnail = "zuljin/47/156066863-avatar.jpg";
 totalHonorableKills = 12519;
 }
 2015-01-21 16:23:03.733 heal drudge[14236:1689842] this spec appears to be Iliss's OS (1): Holy
 2015-01-21 16:23:04.322 heal drudge[14236:1689842] 1: <UIImage: 0x7f9552499260>*/

const NSString *WoWAPIStaminaKey = @"sta";
const NSString *WoWAPIPowerKey = @"power";
const NSString *WoWAPIAgilityKey = @"agi";
const NSString *WoWAPIIntellectKey = @"int";
const NSString *WoWAPIStrengthKey = @"str";
const NSString *WoWAPICritRatingKey = @"critRating";
const NSString *WoWAPIHasteRatingKey = @"hasteRating";
const NSString *WoWAPIMasteryRatingKey = @"masteryRating";
const NSString *WoWAPIVersatilityRatingKey = @"versatility";
const NSString *WoWAPIMultistrikeRatingKey = @"multistrikeKey";
const NSString *WoWAPILeechRatingKey = @"leechRating";
const NSString *WoWAPIArmorRatingKey = @"armor";
const NSString *WoWAPIParryRatingKey = @"parryRating";
const NSString *WoWAPIDodgeRatingKey = @"dodgeRating";
const NSString *WoWAPIBlockRatingKey = @"blockRating";

+ (Entity *)entityWithAPIGuildMemberDict:(NSDictionary *)apiGuildMemberDict fetchingImage:(BOOL)fetchImage
{
    NSDictionary *apiCharacterDict = apiGuildMemberDict[@"character"];
    Entity *entity = [self _entityWithAPICharacterDict:apiCharacterDict fromGuildListRequest:YES fetchingImage:fetchImage];
    entity.guildRank = apiGuildMemberDict[@"rank"];
    return entity;
}

+ (Entity *)entityWithAPICharacterDict:(NSDictionary *)apiCharacterDict fetchingImage:(BOOL)fetchImage
{
    return [self _entityWithAPICharacterDict:apiCharacterDict fromGuildListRequest:NO fetchingImage:fetchImage];
}

+ (Entity *)_entityWithAPICharacterDict:(NSDictionary *)apiCharacterDict fromGuildListRequest:(BOOL)fromGuildListRequest fetchingImage:(BOOL)fetchImage
{
    Entity *entity = [Entity new];
    entity.isComplete = ! fromGuildListRequest;
    entity.name = apiCharacterDict[@"name"];
    entity.realm = [WoWRealm realmWithString:apiCharacterDict[@"realm"]];
    entity.level = apiCharacterDict[@"level"];
    entity.race = apiCharacterDict[@"race"];
    entity.gender = apiCharacterDict[@"gender"];
    entity.achievementPoints = apiCharacterDict[@"achievementPoints"];
    entity.honorableKills = apiCharacterDict[@"totalHonorableKills"];
    NSDictionary *apiItemsDict = apiCharacterDict[@"items"];
    entity.averageItemLevel = apiItemsDict[@"averageItemLevel"];
    entity.averageItemLevelEquipped = apiItemsDict[@"averageItemLevelEquipped"];
    NSArray *apiTalentsArray = apiCharacterDict[@"talents"];
    
    NSNumber *dummyNumber = @999;
    NSDictionary *winningMainSpecDict = nil;
    NSDictionary *runnerUpOffSpecDict = nil;
    for ( NSDictionary *apiTalentDict in apiTalentsArray )
    {
        NSDictionary *apiSpecDict = apiTalentDict[@"spec"];
        NSNumber *thisSpecOrder = apiSpecDict[@"order"];
        if ( [dummyNumber compare:thisSpecOrder] == NSOrderedDescending )
        {
            winningMainSpecDict = apiSpecDict;
            dummyNumber = thisSpecOrder;
        }
        else
            runnerUpOffSpecDict = apiSpecDict;
    }
    
    if ( winningMainSpecDict )
    {
        NSLog(@"%@'s appears to be main %@ OS %@",entity.name,winningMainSpecDict[@"name"],runnerUpOffSpecDict[@"name"]);
        entity.specName = winningMainSpecDict[@"name"];
        
        // TODO?
        //entity.hdClass.role = [WoWAPIRequest roleFromAPIRoleString:winningMainSpecDict[@"role"]];
    }
    entity.offspecName = runnerUpOffSpecDict[@"name"];
    
    entity.hdClass = [HDClass classWithAPICharacterDictionary:apiCharacterDict apiSpecName:entity.specName];
    
    // this is a dictionary for a character request, string name for a guild list
    id apiGuildValue = apiCharacterDict[@"guild"];
    if ( fromGuildListRequest )
    {
        NSString *guildRealm = apiCharacterDict[@"guildRealm"];
        entity.guild = [Guild guildWithAPIName:apiGuildValue apiRealm:guildRealm];
    }
    else
        entity.guild = [Guild guildWithAPIDictionary:apiGuildValue];
    
    NSDictionary *apiStatsDict = apiCharacterDict[@"stats"];
    
    entity.stamina = apiStatsDict[WoWAPIStaminaKey];
    entity.power = apiStatsDict[WoWAPIPowerKey];
    entity.agility = apiStatsDict[WoWAPIAgilityKey];
    entity.strength = apiStatsDict[WoWAPIStrengthKey];
    entity.intellect = apiStatsDict[WoWAPIIntellectKey];
    entity.critRating = apiStatsDict[WoWAPICritRatingKey];
    entity.hasteRating = apiStatsDict[WoWAPIHasteRatingKey];
    entity.masteryRating = apiStatsDict[WoWAPIMasteryRatingKey];
    entity.versatilityRating = apiStatsDict[WoWAPIVersatilityRatingKey];
    entity.multistrikeRating = apiStatsDict[WoWAPIMultistrikeRatingKey];
    entity.leechRating = apiStatsDict[WoWAPILeechRatingKey];
    entity.armor = apiStatsDict[WoWAPIArmorRatingKey];
    entity.parryRating = apiStatsDict[WoWAPIParryRatingKey];
#warning TODO
    //entity.dodgeRating = apiStatsDict[WoWAPIDodgeRatingKey];
    //entity.blockRating = apiStatsDict[WoWAPIBlockRatingKey];
    
    NSArray *apiTitlesArray = apiCharacterDict[@"titles"];
    for ( NSDictionary *apiTitleDict in apiTitlesArray )
    {
        if ( [apiTitleDict[@"selected"] boolValue] )
        {
            NSString *objcFormat = [apiTitleDict[@"name"] stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            entity.titleAndName = [NSString stringWithFormat:objcFormat,entity.name];
        }        
    }
    if ( ! entity.titleAndName )
        entity.titleAndName = entity.name;
 
    if ( fetchImage )
    {
        WoWAPIRequest *fetchRequest = [WoWAPIRequest new];
        fetchRequest.realm = entity.realm;
        fetchRequest.isCharacterThumbnailRequest = YES;
        fetchRequest.characterThumbnailURLSuffix = apiCharacterDict[@"thumbnail"];
 
        [fetchRequest sendRequestWithCompletionHandler:^(BOOL success, id response) {
            if ( ! success )
                NSLog(@"failed to fetch thumbnail image for '%@'",entity);
            else if ( ! [response isKindOfClass:[UIImage class]] )
                NSLog(@"thumbnail image data for '%@' is not an image",entity);
            else
                entity.image = response;
        }];
    }
 
    return entity;
}

const NSString *WoWAPIHealerRoleKey = @"HEALING";
const NSString *WoWAPIDPSRoleKey = @"DPS";
const NSString *WoWAPITankRoleKey = @"TANK";

+ (const NSString *)roleFromAPIRoleString:(NSString *)apiRoleString
{
    if ( [apiRoleString compare:(NSString *)WoWAPIHealerRoleKey options:NSCaseInsensitiveSearch] == NSOrderedSame )
        return HealerRole;
    else if ( [apiRoleString compare:(NSString *)WoWAPIDPSRoleKey options:NSCaseInsensitiveSearch] == NSOrderedSame )
        return DPSRole;
    else if ( [apiRoleString compare:(NSString *)WoWAPITankRoleKey options:NSCaseInsensitiveSearch] == NSOrderedSame )
        return TankRole;
    return nil;
}

+ (id)_recursivelyDeserializedJSONObjectWithData:(NSData *)data error:(NSError **)errorPtr
{
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:errorPtr];
    return object;
    /*if ( [object isKindOfClass:[NSDictionary class]] )
    {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        for ( id key in object )
        {
            id deserializedValue = [self _recursivelyDeserializedJSONObjectWithData:key error:errorPtr];
            if ( deserializedValue )
                [mutableDict setObject:deserializedValue forKey:key];
        }
    }
    else if ( [object isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for ( id subObject in object )
        {
            id deserializedValue = [self _recursivelyDeserializedJSONObjectWithData:subObject error:errorPtr];
            if ( deserializedValue )
                [mutableArray addObject:deserializedValue];
        }
    }
    return object;*/
}

@end
