//
//  LoadCharacterOptionsViewController.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "LoadCharacterOptionsViewController.h"

#import "Entity.h"
#import "Guild.h"
#import "ImageFactory.h"
#import "WoWRealm.h"

@interface LoadCharacterOptionsViewController ()

@end

@implementation LoadCharacterOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ( self.state.player.image )
        self.thumbnailView.image = self.state.player.image;
    else
        self.thumbnailView.image = nil;
    
    if ( self.state.player.name )
        self.nameLabel.text = [NSString stringWithFormat:@"%@-%@",self.state.player.titleAndName,self.state.player.realm.name?self.state.player.realm.name:@"???"];
    else
        self.nameLabel.text = @"???";
    
    if ( self.state.player.specName )
        self.specLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",self.state.player.level?self.state.player.level:@"???",
                               self.state.player.specName,
                               self.state.player.offspecName?self.state.player.offspecName:@"???"];
    else
        self.specLabel.text = @"???";
    
    if ( self.state.player.guild )
        self.guildLabel.text = self.state.player.guild.name;
    else
        self.guildLabel.text = @"???";
    
    if ( self.state.player.averageItemLevel )
        self.ilvlLabel.text = [NSString stringWithFormat:@"%@ ilvl (%@ equipped)",self.state.player.averageItemLevel,
                               self.state.player.averageItemLevelEquipped?self.state.player.averageItemLevelEquipped:@"???"];
    else
        self.ilvlLabel.text = @"???";
    
    self.specView.image = [ImageFactory imageForSpec:self.state.player.hdClass];
    
    self.guildTooSwitch.enabled = ( self.state.player.guild != nil );
}

- (IBAction)ilvlSliderDidSomething:(id)sender
{
    //PHLogV(@"guild ilvl slider did something");
    NSUInteger rounded = self.minGuildiLvlSlider.value;
    [sender setValue:rounded animated:NO];
    self.minGuildiLvlLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.minGuildiLvlSlider.value];
}

- (IBAction)pressedGuildTooButton:(id)sender
{
    [self.guildTooOptionsView setHidden: ! self.guildTooSwitch.on];
}

- (IBAction)pressedSaveButton:(id)sender
{
    // great learning: prepareForSegue:: is the place to pass state like this, synchronization issue done here.
    //self.state.saveGuildToo = self.guildTooSwitch.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.state.saveGuildToo = self.guildTooSwitch.on;
    [super prepareForSegue:segue sender:sender];
}


@end
