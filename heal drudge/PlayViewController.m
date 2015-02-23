//
//  PlayViewController.m
//  heal drudge
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PlayViewController.h"

#import "Encounter.h"
#import "AlertText.h"
#import "PlayView.h"
#import "SpellDragView.h"

@interface PlayViewController ()

// only necessary for leaving view / ending encounter
@property Encounter *encounter;

@end

@implementation PlayViewController

+ (PlayViewController *)playViewController
{
    __block PlayViewController *vc = nil;
    void (^stuffBlock)() = ^{
        vc = [[PlayViewController alloc] initWithNibName:@"PlayView" bundle:nil];
        [vc loadView];
    };
    if ( [NSThread isMainThread] )
        stuffBlock();
    else
        dispatch_sync(dispatch_get_main_queue(), stuffBlock);
    return vc;
}

- (IBAction)menuTouched:(id)sender
{
    [self.encounter end];
    self.encounter = nil;
    self.dismissHandler(self);
}

- (IBAction)commandTouched:(id)sender
{
    SpeechBubbleViewController *speechBubble = [SpeechBubbleViewController speechBubbleViewControllerWithCommands];
    [self _presentSpeechBubble:speechBubble locateBlock:^{
        return CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height);
    }];
}

- (void)_setOrigin:(id)originObject onSpeechBubble:(SpeechBubbleViewController *)speechBubble
{
    CGPoint origin;
    if ( [originObject isKindOfClass:[Entity class]] )
        origin = [self.raidFramesView absoluteOriginForEntity:originObject];
    else // doesn't work
    {
        UIView *view = (UIView *)originObject;
        origin = [self.view convertPoint:view.frame.origin fromView:view];
    }
    speechBubble.bubbleOrigin = origin;
}

typedef CGPoint (^LocateBlock)();
- (void)_presentSpeechBubble:(SpeechBubbleViewController *)speechBubble locateBlock:(LocateBlock)locateBlock
{
    if ( self.currentSpeechBubble )
        self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble, NoCommand, NoMode);
    
    speechBubble.bubbleOrigin = locateBlock();
    speechBubble.referenceView = self.advisorGuideView;
    speechBubble.dismissHandler = ^(SpeechBubbleViewController *vc, PlayerCommand command, MeterMode meterMode){
        [vc.view removeFromSuperview];
        self.currentSpeechBubble = nil;
        
        if ( command != NoCommand )
            [self.encounter handleCommand:command];
        if ( meterMode != NoMode )
            self.meterView.mode = meterMode;
            
    };
    speechBubble.view.frame = self.view.frame;
    [self.view addSubview:speechBubble.view];
    
//#define AUTO_DISMISS_NOTIFICATIONS
#ifdef AUTO_DISMISS_NOTIFICATIONS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( self.currentSpeechBubble )
            self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble);
    });
#endif
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            self.currentSpeechBubble.bubbleOrigin = locateBlock();
            [self _addConstraintsToSpeechBubble:speechBubble];
            [self.currentSpeechBubble.speechBubbleContentView setNeedsLayout];
            [self.currentSpeechBubble.speechBubbleContentView setNeedsDisplay];
        }];
    });
    [self _addConstraintsToSpeechBubble:speechBubble];
    
    self.currentSpeechBubble = speechBubble;
}

- (void)_addConstraintsToSpeechBubble:(SpeechBubbleViewController *)speechBubble
{
    [speechBubble.speechBubbleContentView.superview removeConstraints:self.lastAddedConstraints];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:speechBubble.speechBubbleContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:speechBubble.speechBubbleContentView.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:self.advisorGuideView.frame.origin.x];
    [speechBubble.speechBubbleContentView.superview addConstraint:leadingConstraint];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:speechBubble.speechBubbleContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:speechBubble.speechBubbleContentView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.advisorGuideView.frame.origin.y];
    [speechBubble.speechBubbleContentView.superview addConstraint:topConstraint];
    
    self.lastAddedConstraints = @[ leadingConstraint, topConstraint ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Do any additional setup after loading the view.
    
    Entity *gygias = nil, *slyeri = nil, *lireal = nil;
    NSUInteger size = self.state.raidSize;
    NSUInteger nForced = 0;
    if ( self.state.forceGygias )
    {
        size++;
        nForced++;
    }
    if ( self.state.forceSlyeri )
    {
        size++;
        nForced++;
    }
    if ( self.state.forceLireal )
    {
        size++;
        nForced++;
    }
    Raid *raid = [Raid randomRaidWithGygiasTheDiscPriestAndSlyTheProtPaladin:self.state.forceGygias ? &gygias : NULL
                                                                            :self.state.forceSlyeri ? &slyeri : NULL
                                                                            :self.state.forceLireal ? &lireal : NULL
                                                                        size:size - nForced];
    
    BOOL playSlyeri = [self.state.playerName isEqual:@"Slyeri"];
    BOOL playLireal = [self.state.playerName isEqual:@"Lireal"];
    __block Entity *aHealer = playSlyeri ? slyeri : ( playLireal ? lireal : gygias );
    if ( ! aHealer )
    {
        [raid.players enumerateObjectsUsingBlock:^(Entity *aPlayer, NSUInteger idx, BOOL *stop) {
            if ( aPlayer.hdClass.isHealerClass )
            {
                PHLogV(@"random healer: %@",aPlayer);
                aHealer = aPlayer;
                *stop = YES;
            }
        }];
    }
    aHealer.isPlayingPlayer = YES;
    
    if ( ! aHealer )
    {
        PHLogV(@"there is no healer in this random raid!");
    }
    
    Enemy *enemy = [Enemy randomEnemyWithRaid:raid difficulty:self.state.difficulty];
    self.enemyFrameView.enemy = enemy;
    
    Encounter *encounter = [Encounter new];
    encounter.encounterUpdatedHandler = ^(Encounter *encounter){
        [self _forceDraw:self];
    };
    encounter.enemyAbilityHandler = ^(Enemy *enemy, Ability *ability){
        AlertText *alertText = [AlertText new];
        alertText.text = ability.name;
        alertText.startDate = [NSDate date];
        alertText.duration = 2;
        [self.alertTextView addAlertText:alertText];
    };
    encounter.player = aHealer;
    encounter.raid = raid;
    encounter.enemies = @[ enemy ];
    
    BOOL (^enemyTouchedBlock)(Enemy *);
    enemyTouchedBlock = ^(Enemy *enemy){
        encounter.player.target = enemy;
        self.playerAndTargetView.target = enemy;
        //PHLogV(@"player targeted enemy %@",enemy);
        return YES;
    };
    self.enemyFrameView.enemyTouchedHandler = enemyTouchedBlock;
    
    self.raidFramesView.raid = raid;
    self.raidFramesView.player = aHealer;
    self.raidFramesView.encounter = encounter;
    __unsafe_unretained typeof(self) weakSelf = self;
    self.raidFramesView.targetedPlayerBlock = ^(Entity *target){
        encounter.player.target = target;
        weakSelf.playerAndTargetView.target = target;
        //PHLogV(@"player targeted %@",target);
    };
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_forceDraw:) userInfo:nil repeats:YES];
    
    self.playerAndTargetView.player = aHealer;
    self.playerAndTargetView.entityTouchedHandler = ^(Entity *entity){
        encounter.player.target = entity;
        weakSelf.playerAndTargetView.target = entity;
    };
    self.playerAndTargetView.raidFramesView = self.raidFramesView;
    
    self.spellBarView.player = aHealer;
    BOOL (^castBlock)(Spell *);
    castBlock = ^(Spell *spell) {
        
        // determine target
        Entity *target = nil;
        
        // determine target, shouldn't be doing validation at this level
        if ( spell.targeted && ( encounter.player.target.isEnemy || ! encounter.player.target ) && spell.spellType != DetrimentalSpell )
        {
            PHLogV(@"auto-self casting %@",spell);
            target = encounter.player;
        }
        else
            target = encounter.player.target;
        
        NSString *message = nil;
        
        BOOL doCast = [encounter.player validateSpell:spell asSource:YES otherEntity:target message:&message invalidDueToCooldown:NULL];
        if ( doCast )
        {
            dispatch_async(self.encounter.encounterQueue, ^{
                [encounter.player castSpell:spell withTarget:target];
            });
        }
        else
            PHLogV(@"%@'s %@ failed: %@",encounter.player,spell,message);
        
        return doCast;
    };
    
    self.spellBarView.spellCastAttemptHandler = castBlock;
    self.spellBarView.dragBeganHandler = ^(Spell *spell, CGPoint thePoint) {
        weakSelf.spellDragView.auxiliaryDrawHandler = ^{
            [spell.image drawAtPoint:thePoint blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    self.spellBarView.dragUpdatedHandler = ^(Spell *spell, CGPoint thePoint) {
        weakSelf.spellDragView.auxiliaryDrawHandler = ^{
            [spell.image drawAtPoint:thePoint blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    self.spellBarView.dragEndedHandler = ^(Spell *spell, CGPoint thePoint) {
        if ( ! spell )
        {
            weakSelf.spellDragView.auxiliaryDrawHandler = NULL;
            return;
        }
        
        // fly back to origin
        CGRect returnPoint = [weakSelf.spellBarView rectForSpell:spell];
        returnPoint.origin = [weakSelf.view convertPoint:returnPoint.origin fromView:weakSelf.spellBarView];
        NSDate *flyBackStartDate = [NSDate date];
        NSTimeInterval flyBackDuration = 0.15;
        weakSelf.spellDragView.auxiliaryDrawHandler = ^{
            double currentMoveProgress = [[NSDate date] timeIntervalSinceDate:flyBackStartDate] / flyBackDuration;
            if ( currentMoveProgress > 1 )
            {
                weakSelf.spellDragView.auxiliaryDrawHandler = NULL;
                return;
            }
            CGFloat xDelta = ( returnPoint.origin.x - thePoint.x ) * currentMoveProgress;
            CGFloat yDelta = ( returnPoint.origin.y - thePoint.y ) * currentMoveProgress;
            
            CGRect interpolatedRect = CGRectMake(thePoint.x + xDelta, thePoint.y + yDelta,returnPoint.size.width,returnPoint.size.height);
            [spell.image drawInRect:interpolatedRect blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    
    self.castBarView.entity = encounter.player;
    
    [self _forceDraw:self];
    
    [encounter.enemies enumerateObjectsUsingBlock:^(Enemy *enemy, NSUInteger idx, BOOL *stop) {
        enemy.scheduledSpellHandler = ^(Spell *spell, NSDate *date){
            [self.eventTimerView addSpellEvent:spell date:date];
        };
    }];
    
    encounter.advisor = [Advisor new];
    encounter.advisor.encounter = encounter;
    encounter.advisor.callback = ^(Entity *e, SpeechBubbleViewController *vc) {
        [self _presentSpeechBubble:vc locateBlock:^{
            return [self.raidFramesView absoluteOriginForEntity:e];
        }];
    };
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self.spellBarView invalidateIntrinsicContentSize];
            [self.raidFramesView invalidateIntrinsicContentSize];
        }];
    });
    
    self.miniMapView.encounter = encounter;
    self.meterView.encounter = encounter;
    self.meterView.mode = HealingDoneMode;
    self.meterView.touchedHandler = ^{
        SpeechBubbleViewController *speechBubble = [SpeechBubbleViewController speechBubbleViewControllerWithMeterModes];
        [weakSelf _presentSpeechBubble:speechBubble locateBlock:^{
            return CGPointMake(weakSelf.view.frame.origin.x, weakSelf.view.frame.origin.y + weakSelf.view.frame.size.height);
        }];
    };
    
    if ( ! self.state.debugViews )
    {
        [self.upLeftView setBackgroundColor:[UIColor clearColor]];
        [self.bottomRightView setBackgroundColor:[UIColor clearColor]];
        [self.enemyFrameView setBackgroundColor:[UIColor clearColor]];
        [self.eventTimerView setBackgroundColor:[UIColor clearColor]];
        [self.raidFramesView setBackgroundColor:[UIColor clearColor]];
        [self.playerAndTargetView setBackgroundColor:[UIColor clearColor]];
        [self.castBarView setBackgroundColor:[UIColor clearColor]];
        [self.spellBarView setBackgroundColor:[UIColor clearColor]];
        [self.miniMapView setBackgroundColor:[UIColor clearColor]];
        [self.meterView setBackgroundColor:[UIColor clearColor]];
    }
    
    [encounter start];
    
    self.encounter = encounter;
}

- (void)_forceDraw:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for ( UIView *view in [[self view] subviews] )
        {
            [view setNeedsDisplay];
            for ( UIView *subview in view.subviews )
                [subview setNeedsDisplay];
        }
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
