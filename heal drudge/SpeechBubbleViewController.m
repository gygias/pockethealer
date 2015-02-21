//
//  TankExplanationView.m
//  heal drudge
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
    void (^stuffBlock)() = ^{
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
        if ( weakSelf.dismissHandler )
            weakSelf.dismissHandler(weakSelf);
    };
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
    self.dismissHandler(self);
}

- (IBAction)stackPressed:(id)sender
{
    NSLog(@"STACK!!!");
    self.dismissHandler(self);
}

- (IBAction)spreadPressed:(id)sender
{
    NSLog(@"SPREAD!!!");
    self.dismissHandler(self);
}

@end
