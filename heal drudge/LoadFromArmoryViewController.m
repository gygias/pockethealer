//
//  LoadFromArmoryViewController.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "LoadFromArmoryViewController.h"

#import "WoWAPIRequest.h"
#import "Guild.h"
#import "ImageFactory.h"

@interface LoadFromArmoryViewController ()

@end

@implementation LoadFromArmoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.realmField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEndedEditing:) name:UITextFieldTextDidEndEditingNotification object:self.realmField];
    [self.continueButton setEnabled:NO];
    [self.loadButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldEndedEditing:(id)wut
{
    WoWRealm *suggestedRealm = [WoWRealm realmWithString:self.realmField.text];
    if ( suggestedRealm )
        self.realmField.text = (NSString *)suggestedRealm.name;
    
    [self.loadButton setEnabled:YES];
}

- (void)textFieldChanged:(id)huh
{
    WoWRealm *suggestedRealm = [WoWRealm realmWithString:self.realmField.text];
    //PHLog(@"sup: %@ -> %@",self.realmField.text,suggestedRealm);
    
    NSString *suggestedText = (NSString *)suggestedRealm.name;
    
    NSString *replacementText = self.realmField.text;
    if ( [suggestedText length] > [replacementText length] )
    {
        NSString *remainder = [suggestedText substringFromIndex:[replacementText length]];
        replacementText = [replacementText stringByAppendingString:remainder];
        
        // Get current selected range , this example assumes is an insertion point or empty selection
        UITextRange *selectedRange = [self.realmField selectedTextRange];
        
        self.realmField.text = replacementText;
        
        // Calculate the new position, - for left and + for right
        UITextPosition *newPosition = [self.realmField positionFromPosition:selectedRange.start offset:[remainder length]];
        // Construct a new range using the object that adopts the UITextInput, our textfield
        UITextRange *newRange = [self.realmField textRangeFromPosition:selectedRange.start toPosition:newPosition];
        // Set new range
        [self.realmField setSelectedTextRange:newRange];
    }
    
    [self.loadButton setEnabled:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if ( textField == self.nameField )
//        PHLog(@"name field should");
//    else if ( textField == self.realmField )
//    {
//        PHLog(@"realm field should");
//        //dispatch_async(dispatch_get_current_queue(), ^{
////            WoWRealm *suggestedRealm = [WoWRealm realmWithString:self.realmField.text];
////            if ( suggestedRealm )
////            {
////                self.realmField.text = suggestedRealm.name;
////                UITextRange *range = UITextRange
////                [self.realmField setSelectedTextRange:self.realmField.selectedTextRange.end];
////            }
//        //});
//    }
    return YES;
}

- (IBAction)pressedLoad:(id)sender
{
    for ( id view in [self.view subviews] )
        [view resignFirstResponder];
    
    [self.loadButton setEnabled:NO];
    
    WoWRealm *realm = [WoWRealm realmWithString:self.realmField.text];
    //NSArray *realmCountries = @[ WoWRealmUS, WoWRealmEU, WoWRealmKR, WoWRealmTW];
    //for ( NSString *realmCountry in realmCountries )
    {
        WoWAPIRequest *apiRequest = [WoWAPIRequest new];
        //        apiRequest.isRealmStatusRequest = YES;
        //        apiRequest.realmStatusCountry = realmCountry;
//        apiRequest.realm = zuljinRealm;
//        apiRequest.isGuildMemberListRequest = YES;
//        NSString *guildName = @"Knightfall";
//        apiRequest.guildName = guildName;
        apiRequest.realm = realm;
        apiRequest.isCharacterInfoRequest = YES;
        apiRequest.characterName = self.nameField.text;
        [apiRequest sendRequestWithCompletionHandler:^(BOOL success, id response) {
            PHLog(@"initial character load claims %@",success?@"success":@"failure");
            //PHLog(@"%@",response);
            
            if ( ! success || ! [response isKindOfClass:[NSDictionary class]] )
            {
                [self.loadButton setEnabled:YES];
                [self.continueButton setEnabled:NO];
                self.thumbnailView.image = nil;
                self.nameLabel.text = @"???";
                self.specLabel.text = @"???";
                self.guildLabel.text = @"???";
                return;
            }
//            PHLog(@"%@",[WoWAPIRequest characterNamesFromGuildListResponse:response]);
//            
//            NSUInteger randomIndex = arc4random() % [response count];
//            NSDictionary *aAPICharacterGuildDict = [[response objectForKey:@"members"] objectAtIndex:randomIndex]; // XXX
//            NSDictionary *aAPICharacterDict = aAPICharacterGuildDict[@"character"]; // also includes a 'rank' number
//            PHLog(@"%@",aAPICharacterDict);
            Entity *entity =     [WoWAPIRequest entityWithAPICharacterDict:response
                                                                fetchingImage:YES];
//            character.guildName = guildName;
            if ( entity.image )
                self.thumbnailView.image = entity.image;
            else
                self.thumbnailView.image = nil;
            
            if ( entity.name )
                self.nameLabel.text = [NSString stringWithFormat:@"%@-%@",entity.titleAndName,entity.realm.name?entity.realm.name:@"???"];
            else
                self.nameLabel.text = @"???";
            
            if ( entity.specName )
                self.specLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",entity.level?entity.level:@"???",entity.specName,entity.offspecName?entity.offspecName:@"???"];
            else
                self.specLabel.text = @"???";
            
            if ( entity.guild )
                self.guildLabel.text = entity.guild.name;
            else
                self.guildLabel.text = @"???";
            
            if ( entity.averageItemLevel )
                self.ilvlLabel.text = [NSString stringWithFormat:@"%@ ilvl (%@ equipped)",entity.averageItemLevel,entity.averageItemLevelEquipped?entity.averageItemLevelEquipped:@"???"];
            else
                self.ilvlLabel.text = @"???";
            
            self.specView.image = [ImageFactory imageForSpec:entity.hdClass];
            
            //            NSArray *realmsArray = [WoWAPIRequest realmsFromRealmStatusResponse:response country:realmCountry];
            //            PHLog(@"%@",realmsArray);
            //            NSArray *realmsPlist = [WoWRealm realmsAsPropertyList:realmsArray];
            //
            //            NSString *filePath = @"/tmp/Realms.plist";
            //            NSMutableDictionary *fileDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            //            if ( ! fileDict )
            //                fileDict = [NSMutableDictionary dictionary];
            //            fileDict[apiRequest.realmStatusCountry] = realmsPlist;
            //            [fileDict writeToFile:filePath atomically:YES];
            
            [self.loadButton setEnabled:NO];
            [self.continueButton setEnabled:YES];
            
            self.state.player = entity;
        }];
    }
}

- (IBAction)pressedContinue:(id)sender
{
    PHLog(@"continue...");
}

@end
