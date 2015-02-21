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
    self.dismissHandler(self);
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
        if ( vc && e && ! self.currentSpeechBubble )
        {
            [NSDate pause];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDate *showDate = [NSDate date];
                self.currentSpeechBubble = vc;
                vc.dismissHandler = ^(SpeechBubbleViewController *vc) {
                    NSTimeInterval shownInterval = [[NSDate date] timeIntervalSinceDate:showDate];
                    PHLogV(@"adding pause time: %0.2f",shownInterval);
                    [NSDate unpause];
                    [vc.view removeFromSuperview];
                    self.currentSpeechBubble = nil;
                };
                //#define AUTO_DISMISS_NOTIFICATIONS
#ifdef AUTO_DISMISS_NOTIFICATIONS
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ( self.currentSpeechBubble )
                        self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble);
                });
#endif
                vc.bubbleOrigin = [self.raidFramesView absoluteOriginForEntity:e];
                vc.referenceView = self.advisorGuideView;
                vc.view.frame = self.view.frame;
                //[vc.speechBubbleContentView removeFromSuperview];
                //[self.advisorGuideView addSubview:vc.speechBubbleContentView];
                [self.view addSubview:vc.view];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:vc.speechBubbleContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:vc.speechBubbleContentView.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:self.advisorGuideView.frame.origin.x];
                [vc.speechBubbleContentView.superview addConstraint:constraint];
                constraint = [NSLayoutConstraint constraintWithItem:vc.speechBubbleContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:vc.speechBubbleContentView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.advisorGuideView.frame.origin.y];
                [vc.speechBubbleContentView.superview addConstraint:constraint];
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                        //if ( self.currentSpeechBubble )
                        //    self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble);
                        [self.spellBarView invalidateIntrinsicContentSize];
                        [self.raidFramesView invalidateIntrinsicContentSize];
                        self.currentSpeechBubble.bubbleOrigin = [self.raidFramesView absoluteOriginForEntity:e];
                    }];
                });
            });
        }
    };
    
    self.miniMapView.encounter = encounter;
    
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
