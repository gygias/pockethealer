//
//  TankExplanationView.m
//  pockethealer
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpeechBubbleViewController.h"

#import "SpeechBubbleView.h"

@implementation SpeechBubbleViewController

+ (SpeechBubbleViewController *)_speechBubbleViewControllerWithNib:(NSString *)nibName
{
    __block SpeechBubbleViewController *vc = nil;
    void (^stuffBlock)(void) = ^{
        vc = [[SpeechBubbleViewController alloc] initWithNibName:nibName bundle:nil];
        [vc loadView];
    };
    if ( [NSThread isMainThread] )
        stuffBlock();
    else
        dispatch_sync(dispatch_get_main_queue(), stuffBlock);
    return vc;
}

+ (SpeechBubbleViewController *)speechBubbleViewControllerWithImage:(UIImage *)image text:(NSString *)text
{
    SpeechBubbleViewController *vc = [self _speechBubbleViewControllerWithNib:@"SpeechBubbleImageAndTextView"];
    vc.imageView.image = image;
    vc.textLabel.text = text;
    return vc;
}

+ (SpeechBubbleViewController *)speechBubbleViewControllerWithCommands
{
    SpeechBubbleViewController *vc = [self _speechBubbleViewControllerWithNib:@"SpeechBubbleCommandsView"];
    vc.speechBubbleView.isCommandView = YES;
    return vc;
}

+ (SpeechBubbleViewController *)speechBubbleViewControllerWithMeterModes
{
    SpeechBubbleViewController *vc = [self _speechBubbleViewControllerWithNib:@"SpeechBubbleMeterModeView"];
    vc.speechBubbleView.isMeterModeView = YES;
    return vc;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //[super viewDidLoad];
}

- (void)setBubbleOrigin:(CGPoint)bubbleOrigin
{
    ((SpeechBubbleView *)self.view.subviews.firstObject).bubbleOrigin = bubbleOrigin;
    
    // XXX
    __unsafe_unretained typeof(self) weakSelf = self;
    self.speechBubbleContentView.dismissHandler = ^(SpeechBubbleContentView *view) {
        if ( weakSelf.speechBubbleView.isCommandView )
            return;
        if ( weakSelf.shouldDismissHandler && ! weakSelf.shouldDismissHandler(weakSelf) )
            return;
        if ( weakSelf.dismissHandler )
            weakSelf.dismissHandler(weakSelf, NoCommand, NoMode);
    };
}

- (UIView *)referenceView
{
    return ((SpeechBubbleView *)self.view.subviews.firstObject).referenceView;
}

- (void)setReferenceView:(UIView *)referenceView
{
    ((SpeechBubbleView *)self.view.subviews.firstObject).referenceView = referenceView;
}

- (CGPoint)bubbleOrigin
{
    return ((SpeechBubbleView *)self.view.subviews.firstObject).bubbleOrigin;
}

- (IBAction)heroPressed:(id)sender
{
    NSLog(@"HERO!!!");
    self.dismissHandler(self, HeroCommand, NoMode);
}

- (IBAction)stackInMeleePressed:(id)sender
{
    NSLog(@"STACK IN MELEE!!!");
    self.dismissHandler(self, StackInMeleeCommand, NoMode);
}

- (IBAction)stackOnMePressed:(id)sender
{
    NSLog(@"STACK ON ME!!!");
    self.dismissHandler(self, StackOnMeCommand, NoMode);
}

- (IBAction)spreadPressed:(id)sender
{
    NSLog(@"SPREAD!!!");
    self.dismissHandler(self, SpreadCommand, NoMode);
}

- (IBAction)idiotsPressed:(id)sender
{
    NSLog(@"IDIOTS!!!");
    self.dismissHandler(self, IdiotsCommand, NoMode);
}

- (IBAction)showHealingPressed:(id)sender
{
    NSLog(@"show healing done");
    self.dismissHandler(self, NoCommand, HealingDoneMode);
}
- (IBAction)showOverhealingPressed:(id)sender
{
    NSLog(@"show overhealing");
    self.dismissHandler(self, NoCommand, OverhealingMode);
}
- (IBAction)showHealingTakenPressed:(id)sender
{
    NSLog(@"show healing taken");
    self.dismissHandler(self, NoCommand, HealingTakenMode);
}
- (IBAction)showDamagePressed:(id)sender
{
    NSLog(@"show damage done");
    self.dismissHandler(self, NoCommand, DamageDoneMode);
}
- (IBAction)showDamageTakenPressed:(id)sender
{
    NSLog(@"show damage taken");
    self.dismissHandler(self, NoCommand, DamageTakenMode);
}

@end
