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
    void (^stuffBlock)(void) = ^{
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
        return [self _absoluteBottomLeft];
    }];
    
    [self.encounter pause];
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

typedef CGPoint (^LocateBlock)(void);
- (void)_presentSpeechBubble:(SpeechBubbleViewController *)speechBubble locateBlock:(LocateBlock)locateBlock
{
    if ( self.currentSpeechBubble )
        self.currentSpeechBubble.dismissHandler(self.currentSpeechBubble, NoCommand, NoMode);
    
    speechBubble.bubbleOrigin = locateBlock();
    if ( CGRectContainsPoint(self.advisorGuideMask.frame, speechBubble.bubbleOrigin) )
        speechBubble.referenceView = self.advisorGuideViewTop;
    else
        speechBubble.referenceView = self.advisorGuideView;
    speechBubble.dismissHandler = ^(SpeechBubbleViewController *vc, PlayerCommand command, MeterMode meterMode){
        [vc.view removeFromSuperview];
        self.currentSpeechBubble = nil;
        
        if ( command != NoCommand )
            [self.encounter handleCommand:command];
        if ( meterMode != NoMode )
            self.meterView.mode = meterMode;
        
        if ( self.encounter.isPaused )
            [self.encounter unpause];
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
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:speechBubble.speechBubbleContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:speechBubble.speechBubbleContentView.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:speechBubble.referenceView.frame.origin.x];
    [speechBubble.speechBubbleContentView.superview addConstraint:leadingConstraint];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:speechBubble.speechBubbleContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:speechBubble.speechBubbleContentView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:speechBubble.referenceView.frame.origin.y];
    [speechBubble.speechBubbleContentView.superview addConstraint:topConstraint];
    
    self.lastAddedConstraints = @[ leadingConstraint, topConstraint ];
}

- (void)_configure
{
    Entity *gygias = nil, *slyeri = nil, *lireal = nil;
    NSUInteger size = self.state.raidSize;
    NSUInteger nForced = 0;
    NSArray *forceKeys = @[ @"forceGygias", @"forceSlyeri", @"forceLireal" ];
    for ( NSString *forceKey in forceKeys )
    {
        if ( [[self.state valueForKey:forceKey] boolValue] )
        {
            size++;
            nForced++;
        }
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
    raid.player = aHealer;
    
    if ( ! aHealer )
    {
        PHLogV(@"there is no healer in this random raid!");
    }
    
    Enemy *enemy = [Enemy randomEnemyWithRaid:raid difficulty:self.state.difficulty];
    self.enemyFrameView.enemy = enemy;
    
    Encounter *encounter = [Encounter new];
    encounter.encounterUpdatedHandler = ^(Encounter *encounter){
        [self _draw:StateDrawMode | RealTimeDrawMode];
    };
    encounter.enemyAbilityHandler = ^(Enemy *enemy, Ability *ability){
        AlertText *alertText = [AlertText new];
        alertText.text = ability.name;
        alertText.startDate = [NSDate date];
        alertText.duration = 2;
        [self.alertTextView addAlertText:alertText];
    };
    encounter.encounterUpdatedEntityPositionsHandler = ^(Encounter *encounter, Entity *entity)
    {
        [self _draw:PositionalDrawMode | RealTimeDrawMode];
    };
    encounter.player = aHealer;
    encounter.raid = raid;
    encounter.enemies = @[ enemy ];

    // FRAME VIEWS
#pragma mark frame views setup
    
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
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_draw:) userInfo:nil repeats:YES];
    
    self.playerAndTargetView.player = aHealer;
    self.playerAndTargetView.entityTouchedHandler = ^(Entity *entity){
        encounter.player.target = entity;
        weakSelf.playerAndTargetView.target = entity;
    };
    self.playerAndTargetView.raidFramesView = self.raidFramesView;
    
    // CAST AND SPELL BAR
#pragma mark cast and spell bar setup
    
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
        weakSelf.spellDragView.spellDragDrawHandler = ^(CGRect rect){
            [spell.image drawAtPoint:thePoint blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    self.spellBarView.dragUpdatedHandler = ^(Spell *spell, CGPoint thePoint) {
        weakSelf.spellDragView.spellDragDrawHandler = ^(CGRect rect){
            [spell.image drawAtPoint:thePoint blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    self.spellBarView.dragEndedHandler = ^(Spell *spell, CGPoint thePoint) {
        if ( ! spell )
        {
            weakSelf.spellDragView.spellDragDrawHandler = NULL;
            return;
        }
        
        // fly back to origin
        CGRect returnPoint = [weakSelf.spellBarView rectForSpell:spell];
        returnPoint.origin = [weakSelf.view convertPoint:returnPoint.origin fromView:weakSelf.spellBarView];
        NSDate *flyBackStartDate = [NSDate date];
        NSTimeInterval flyBackDuration = 0.25;
        weakSelf.spellDragView.spellDragDrawHandler = ^(CGRect rect){
            double currentMoveProgress = [[NSDate date] timeIntervalSinceDate:flyBackStartDate] / flyBackDuration;
            if ( currentMoveProgress > 1 )
            {
                weakSelf.spellDragView.spellDragDrawHandler = NULL;
                return;
            }
            CGFloat xDelta = ( returnPoint.origin.x - thePoint.x ) * currentMoveProgress;
            CGFloat yDelta = ( returnPoint.origin.y - thePoint.y ) * currentMoveProgress;
            
            CGRect interpolatedRect = CGRectMake(thePoint.x + xDelta, thePoint.y + yDelta,returnPoint.size.width,returnPoint.size.height);
            [spell.image drawInRect:interpolatedRect blendMode:kCGBlendModeNormal alpha:0.5];
        };
    };
    
    self.castBarView.entity = encounter.player;
    
    // EVENTS
#pragma mark events setup
    
    [encounter.enemies enumerateObjectsUsingBlock:^(Enemy *enemy, NSUInteger idx, BOOL *stop) {
        enemy.scheduledSpellHandler = ^(Spell *spell, NSDate *date){
            [self.eventTimerView addSpellEvent:spell date:date];
        };
    }];
    
    encounter.advisor = [Advisor new];
    encounter.advisor.encounter = encounter;
    encounter.advisor.playView = self;
    encounter.advisor.callback = ^(id thing, SpeechBubbleViewController *vc) {
        
        if ( [thing isKindOfClass:[NSNumber class]] && [thing integerValue] == UIExplanationEnd )
        {
            NSLog(@"removing touch view");
            UIView *superview = weakSelf.touchDemoView.superview;
            [weakSelf.touchDemoView removeFromSuperview];
            weakSelf.spellDragView.touchDemoDrawHandler = NULL;
            [self.currentSpeechBubble.view removeFromSuperview];
            [superview setNeedsDisplay];
            return;
        }
        
        CGPoint location = [self _originForThing:thing];
        [self _presentSpeechBubble:vc locateBlock:^{
            return [self _originForThing:thing];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( ! weakSelf.touchDemoView )
                weakSelf.touchDemoView = [TouchDemoView new];
            weakSelf.spellDragView.touchDemoDrawHandler = ^(CGRect rect){
                [weakSelf.touchDemoView drawRect:rect];
            };
            [weakSelf.touchDemoView moveTo:location];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MOVE_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.touchDemoView doTouch];
                if ( [thing isKindOfClass:[Entity class]] )
                {
                    NSLog(@"touching %@",thing);
                    Entity *entity = thing;
                    if ( entity.isEnemy )
                        self.enemyFrameView.enemyTouchedHandler((Enemy *)entity);
                    else if ( entity.isPlayingPlayer )
                        self.playerAndTargetView.entityTouchedHandler(entity);
                    else
                        self.raidFramesView.targetedPlayerBlock(entity);
                }
                else if ( [thing isKindOfClass:[NSNumber class]] )
                {
                    Entity *randomNonPlayingPlayer = self.encounter.raid.players.randomObject;
                    while ( self.encounter.raid.players.count > 1 && randomNonPlayingPlayer.isPlayingPlayer )
                        randomNonPlayingPlayer = self.encounter.raid.players.randomObject;
                    
                    AdvisorUIExplanationState state = ((NSNumber *)thing).integerValue;
                    switch(state)
                    {
                        case UIExplanationEnemyAwaitingTouch:
                        case UIExplanationEnemyTouched:
                            NSLog(@"touching random enemy");
                            self.enemyFrameView.enemyTouchedHandler(self.encounter.enemies.randomObject);
                            break;
                        case UIExplanationRaidFramesAwaitingTouch:
                        case UIExplanationRaidFramesTouched:
                            NSLog(@"touching random player");
                            self.raidFramesView.targetedPlayerBlock(randomNonPlayingPlayer);
                            break;
                        case UIExplanationPlayerAndTargetAwaitingPlayer:
                        case UIExplanationPlayerAndTargetPlayer:
                            NSLog(@"touching player");
                            self.playerAndTargetView.entityTouchedHandler(self.encounter.player);
                            break;
                        case UIExplanationPlayerAndTargetAwaitingTarget:
                        case UIExplanationPlayerAndTargetTarget:
                            NSLog(@"touching player target");
                            self.playerAndTargetView.entityTouchedHandler(randomNonPlayingPlayer);
                            break;
                        case UIExplanationPlayerAndTargetAwaitingTargetTarget:
                        case UIExplanationPlayerAndTargetTargetTarget:
                            NSLog(@"touching player target target");
                            self.playerAndTargetView.entityTouchedHandler(self.encounter.player.target.target);
                            break;
                        case UIExplanationSpellBarAwaitingCastTimeSpell:
                        case UIExplanationSpellBarDidCastCastTimeSpell:
                            NSLog(@"touching spell ???");
                            {
                                Spell *touchSpell = [self.spellBarView _explanationSpell];
                                self.spellBarView.spellCastAttemptHandler(touchSpell);
                            }
                            break;
                        case UIExplanationCastBar:
                            NSLog(@"touching cast bar ???");
                            break;
                        case UIExplanationMiniMap:
                            NSLog(@"touching minimap");
                            break;
                        case UIExplanationMeter:
                            NSLog(@"touching meter");
                            break;
                        case UIExplanationCommandButton:
                            NSLog(@"touching command button");
                            break;
                        default:
                            NSLog(@"touching ???: %@",thing);
                            break;
                    }
                }
            });
        });
    };
    if ( self.isHowToPlayViewController )
        encounter.advisor.mode = HowToPlayAdvisorAuto;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self.spellBarView invalidateIntrinsicContentSize];
            [self.raidFramesView invalidateIntrinsicContentSize];
        }];
    });
    
    self.miniMapView.encounter = encounter;
    self.meterView.encounter = encounter;
    NSInteger stateMode = [State sharedState].meterMode;
    self.meterView.mode = stateMode != NoMode ? stateMode : HealingDoneMode;
    self.meterView.touchedHandler = ^{
        SpeechBubbleViewController *speechBubble = [SpeechBubbleViewController speechBubbleViewControllerWithMeterModes];
        [weakSelf _presentSpeechBubble:speechBubble locateBlock:^{
            return [weakSelf _absoluteBottomLeft];
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
    
    self.encounter = encounter;
}

- (CGPoint)_originForThing:(id)thing
{
    if ( [thing isKindOfClass:[Entity class]] )
        [self.raidFramesView absoluteOriginForEntity:thing];
    else if ( [thing isKindOfClass:[UIView class]] )
        return [self _centerOfView:thing];
    else if ( [thing isKindOfClass:[NSNumber class]] )
    {
        AdvisorUIExplanationState state = ((NSNumber *)thing).integerValue;
        switch(state)
        {
            case UIExplanationEnemyAwaitingTouch:
            case UIExplanationEnemyTouched:
                return [self _centerOfView:self.enemyFrameView];
            case UIExplanationRaidFramesAwaitingTouch:
            case UIExplanationRaidFramesTouched:
                return [self _centerOfView:self.raidFramesView];
            case UIExplanationPlayerAndTargetAwaitingPlayer:
            case UIExplanationPlayerAndTargetPlayer:
                return [self.view convertPoint:self.playerAndTargetView.centerOfPlayer fromView:self.playerAndTargetView];
            case UIExplanationPlayerAndTargetAwaitingTarget:
            case UIExplanationPlayerAndTargetTarget:
                return [self.view convertPoint:self.playerAndTargetView.centerOfTarget fromView:self.playerAndTargetView];
            case UIExplanationPlayerAndTargetAwaitingTargetTarget:
            case UIExplanationPlayerAndTargetTargetTarget:
                return [self.view convertPoint:self.playerAndTargetView.centerOfTargetTarget fromView:self.playerAndTargetView];
            case UIExplanationSpellBarAwaitingCastTimeSpell:
            case UIExplanationSpellBarDidCastCastTimeSpell:
                NSLog(@"-> center of spell bar view");
                return [self _centerOfView:self.spellBarView];
            case UIExplanationCastBar:
                NSLog(@"-> center of cast bar view");
                return [self _centerOfView:self.castBarView];
            case UIExplanationMiniMap:
                NSLog(@"-> center of mini map view");
                return [self _centerOfView:self.miniMapView];
            case UIExplanationMeter:
                NSLog(@"-> center of meter view");
                return [self _centerOfView:self.meterView];
            case UIExplanationCommandButton:
                NSLog(@"-> center of command button");
                return [self _centerOfView:self.commandButton];
            default:
                break;
        }
    }
    return [self _absoluteBottomRight];
}

- (CGPoint)_centerOfView:(UIView *)view
{
    CGPoint subviewMidPoint;
    if ( view == self.spellBarView )
        subviewMidPoint = [self.spellBarView _explanationSpellCenter];
    else
        subviewMidPoint = CGRectGetMid(view.frame);
    CGPoint centerPoint;
    if ( view == self.miniMapView || view == self.meterView )
        centerPoint = subviewMidPoint;
    else
        centerPoint = [self.view convertPoint:subviewMidPoint fromView:view];
    if ( view == self.commandButton )
    {
        centerPoint.x -= 5;
        centerPoint.y -= 20;
    }
    //NSLog(@"the center of %@: (%@) is %@",view,PointString(subviewMidPoint),PointString(centerPoint));
    return centerPoint;
}

- (CGPoint)_absoluteBottomLeft
{
    return CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height);
}

- (CGPoint)_absoluteBottomRight
{
    return CGPointMake(self.view.frame.origin.x + self.view.frame.size.width, self.view.frame.origin.y + self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _configure];
    [self _draw:AllDrawModes];
    
    [self.encounter start];
}

- (void)_draw:(PlayViewDrawMode)drawMode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDate *now = [NSDate date];
//#define THROTTLE_DRAWS
#ifdef THROTTLE_DRAWS
        NSTimeInterval timeUntilNextRealTimeDraw = 0;
        if ( self.lastDrawDate && ( timeUntilNextRealTimeDraw = [now timeIntervalSinceDate:self.lastDrawDate] ) < REAL_TIME_DRAWING_INTERVAL )
        {
            if ( ! self.drawQueued )
            {
                self.drawQueued = YES;
                //NSLog(@"throttled draw by %0.3f",timeUntilNextRealTimeDraw);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeUntilNextRealTimeDraw * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.lastDrawDate = nil;
                    self.drawQueued = NO;
                    [self _draw:drawMode];
                });
            }
            return;
        }
#endif
        self.lastDrawDate = now;
        
        for ( UIView *view in [[self view] subviews] )
        {
            //[view setNeedsDisplay];
            for ( UIView *subview in view.subviews )
            {
                BOOL update = YES;
                if ( [subview isKindOfClass:[PlayViewBase class]] )
                {
                    PlayViewDrawMode subviewDrawMode = ((PlayViewBase *)subview).playViewDrawMode;
                    update = ( subviewDrawMode & drawMode );
                }
                if ( update )
                    [subview setNeedsDisplay];
            }
        }
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
