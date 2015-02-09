//
//  QuickPlayViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "QuickPlayViewController.h"

#import "Encounter.h"
#import "AlertText.h"

@interface QuickPlayViewController ()

// only necessary for leaving view / ending encounter
@property Encounter *encounter;

@end

@implementation QuickPlayViewController

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
    
    Enemy *enemy = [Enemy randomEnemyWithRaid:raid];
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
    self.raidFramesView.targetedPlayerBlock = ^(Entity *target){
        encounter.player.target = target;
        self.playerAndTargetView.target = target;
        //PHLogV(@"player targeted %@",target);
    };
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_forceDraw:) userInfo:nil repeats:YES];

    self.playerAndTargetView.player = aHealer;
    self.playerAndTargetView.entityTouchedHandler = ^(Entity *entity){
        encounter.player.target = entity;
        self.playerAndTargetView.target = entity;
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
            [encounter.player castSpell:spell withTarget:target];
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
                self.currentSpeechBubble.dismissHandler = ^(SpeechBubbleViewController *vc) {
                    NSTimeInterval shownInterval = [[NSDate date] timeIntervalSinceDate:showDate];
                    NSLog(@"adding pause time: %0.2f",shownInterval);
                    [NSDate unpause];
                    [vc.view removeFromSuperview];
                    self.currentSpeechBubble = nil;
                };
                vc.bubbleOrigin = [self.raidFramesView originForEntity:e];
                //[contentView removeFromSuperview];
                //NSLog(@"forwarding (%f,%f),[%f,%f]",self.advisorGuideView.frame.origin.x,self.advisorGuideView.frame.origin.y,self.advisorGuideView.frame.size.width,self.advisorGuideView.frame.size.height);
                vc.referenceView = self.advisorGuideView;
                vc.view.frame = self.view.frame;
                //[vc.speechBubbleContentView removeFromSuperview];
                //[self.advisorGuideView addSubview:vc.speechBubbleContentView];
                [self.view addSubview:vc.view];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:vc.speechBubbleContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:vc.speechBubbleContentView.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:self.advisorGuideView.frame.origin.x];
                [vc.speechBubbleContentView.superview addConstraint:constraint];
                constraint = [NSLayoutConstraint constraintWithItem:vc.speechBubbleContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:vc.speechBubbleContentView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.advisorGuideView.frame.origin.y];
                [vc.speechBubbleContentView.superview addConstraint:constraint];
                [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                    if ( self.currentSpeechBubble )
                    {
                        self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble);
                        self.currentSpeechBubble = nil;
                    }
                }];
                //[vc.speechBubbleContentView addConstraint:[NSLayoutConstraint constraintWithItem:vc.speechBubbleContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.advisorGuideView attribute:NSLayoutAttributeLeading multiplier:0 constant:0]];
                //vc.speechBubbleContentView.frame = self.advisorGuideView.frame;
                //[self.advisorGuideView addSubview:contentView];
                //vc.speechBubbleContentView.bounds = self.advisorGuideView.bounds;
            });
        }
    };
    
    [encounter start];
    
    self.encounter = encounter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self.encounter end];
}

@end
