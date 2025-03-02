//
//  CreateHealerViewController.m
//  pockethealer
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "CreateHealerViewController.h"

#import "Entity.h"

#define NUM_SECONDARIES 3

@interface CreateHealerViewController ()

@end

#define HD_NAME_MIN 3
#define HD_NAME_MAX 12

@implementation CreateHealerViewController

- (void)_refreshState
{
    self.ilvlValueLabel.text = [NSString stringWithFormat:@"%0.0f",self.ilvlSlider.value];
    self.createButton.enabled = ( self.nameField.text.length >= HD_NAME_MIN
                                 && self.nameField.text.length <= HD_NAME_MAX );
    
    NSInteger selectedPreferredSecondaryOne = self.preferredSecondaryOneSelector.selectedSegmentIndex;
    if ( self.preferredSecondaryTwoSelector.selectedSegmentIndex == selectedPreferredSecondaryOne )
        self.preferredSecondaryTwoSelector.selectedSegmentIndex = ( selectedPreferredSecondaryOne + 1 ) % NUM_SECONDARIES;
    {
        [self.preferredSecondaryTwoSelector setEnabled:NO forSegmentAtIndex:selectedPreferredSecondaryOne];
        [self.preferredSecondaryTwoSelector setEnabled:YES forSegmentAtIndex:( selectedPreferredSecondaryOne + 1 ) % NUM_SECONDARIES];
        [self.preferredSecondaryTwoSelector setEnabled:YES forSegmentAtIndex:( selectedPreferredSecondaryOne + 2 ) % NUM_SECONDARIES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _refreshState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    PHLogV(@"name field should blah blah");
    [self _refreshState];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    PHLogV(@"name field did end editing");
    [self _refreshState];
}

- (IBAction)nameFieldDidSomething:(id)sender
{
    PHLogV(@"name field did something");
    [self _refreshState];
}

- (IBAction)classSelectorDidSomething:(id)sender
{
    PHLogV(@"class selector did something");
    [self _refreshState];
}

- (IBAction)ilvlSliderDidSomething:(id)sender
{
    //PHLogV(@"ilvl slider did something");
    [self _refreshState];
}

- (IBAction)preferredSecondaryOneSelectorDidSomething:(id)sender
{
    PHLogV(@"preferred secondary one did something");
    [self _refreshState];
}

- (IBAction)preferredSecondaryTwoSelectorDidSomething:(id)sender
{
    PHLogV(@"preferred secondary two did something");
    [self _refreshState];
}

- (IBAction)createButtonTapped:(id)sender
{
    PHLogV(@"create button tapped");
    
    [self performSegueWithIdentifier:@"create-main" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PHLogV(@"prepare for segue: %@: %@",sender,segue);
}


@end
