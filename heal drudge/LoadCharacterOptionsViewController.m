//
//  LoadCharacterOptionsViewController.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "LoadCharacterOptionsViewController.h"

#import "Character.h"
#import "ImageFactory.h"

@interface LoadCharacterOptionsViewController ()

@end

@implementation LoadCharacterOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ( self.state.character.image )
        self.thumbnailView.image = self.state.character.image;
    else
        self.thumbnailView.image = nil;
    
    if ( self.state.character.name )
        self.nameLabel.text = [NSString stringWithFormat:@"%@-%@",self.state.character.titleAndName,self.state.character.realm.name?self.state.character.realm.name:@"???"];
    else
        self.nameLabel.text = @"???";
    
    if ( self.state.character.specName )
        self.specLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",self.state.character.level?self.state.character.level:@"???",
                               self.state.character.specName,
                               self.state.character.offspecName?self.state.character.offspecName:@"???"];
    else
        self.specLabel.text = @"???";
    
    if ( self.state.character.guild )
        self.guildLabel.text = self.state.character.guild.name;
    else
        self.guildLabel.text = @"???";
    
    if ( self.state.character.averageItemLevel )
        self.ilvlLabel.text = [NSString stringWithFormat:@"%@ ilvl (%@ equipped)",self.state.character.averageItemLevel,
                               self.state.character.averageItemLevelEquipped?self.state.character.averageItemLevelEquipped:@"???"];
    else
        self.ilvlLabel.text = @"???";
    
    self.specView.image = [ImageFactory imageForSpec:self.state.character.hdClass];
    
    self.guildTooSwitch.enabled = self.state.character.guild;
}

- (IBAction)ilvlSliderDidSomething:(id)sender
{
    //NSLog(@"guild ilvl slider did something");
    NSUInteger rounded = self.minGuildiLvlSlider.value;
    [sender setValue:rounded animated:NO];
    self.minGuildiLvlLabel.text = [NSString stringWithFormat:@"%lu",(NSUInteger)self.minGuildiLvlSlider.value];
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
