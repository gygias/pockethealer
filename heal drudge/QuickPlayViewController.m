//
//  QuickPlayViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

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
    Raid *raid = [Raid randomRaidWithGygiasTheDiscPriestAndSlyTheProtPaladin:&gygias :&slyeri :&lireal];
    
    BOOL playSlyeri = [self.state.playerName isEqual:@"Slyeri"];
    BOOL playLireal = [self.state.playerName isEqual:@"Lireal"];
    /*__block*/ Entity *aHealer = playSlyeri ? slyeri : ( playLireal ? lireal : gygias );
    aHealer.isPlayingPlayer = YES;
    /*[raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player *player = (Player *)obj;
        if ( player.character.hdClass.isHealerClass )
        {
            NSLog(@"random healer: %@",player);
            aHealer = player;
            *stop = YES;
        }
    }];*/
    
    if ( ! aHealer )
    {
        NSLog(@"there is no healer in this random raid!");
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
        NSLog(@"player targeted enemy %@",enemy);
        return YES;
    };
    self.enemyFrameView.enemyTouchedHandler = enemyTouchedBlock;
    
    self.raidFramesView.raid = raid;
    self.raidFramesView.player = aHealer;
    self.raidFramesView.encounter = encounter;
    self.raidFramesView.targetedPlayerBlock = ^(Entity *target){
        encounter.player.target = target;
        self.playerAndTargetView.target = target;
        NSLog(@"player targeted %@",target);
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
        if ( spell.targeted && encounter.player.target.isEnemy && spell.spellType == BeneficialSpell )
        {
            NSLog(@"auto-self casting %@",spell);
            target = encounter.player;
        }
        else
            target = encounter.player.target;
        
        NSString *message = nil;
        
        BOOL doCast = [encounter.player validateSpell:spell asSource:YES otherEntity:target message:&message invalidDueToCooldown:NULL];
        if ( doCast )
        {
            NSNumber *effectiveCastTime = [encounter.player castSpell:spell withTarget:target];
            self.castBarView.castingEntity = encounter.player;
            self.castBarView.effectiveCastTime = effectiveCastTime;
        }
        else
            NSLog(@"%@'s %@ failed: %@",encounter.player,spell,message);
        
        return doCast;
    };
    
    self.spellBarView.spellCastAttemptHandler = castBlock;
    
    [self _forceDraw:self];
    
    [encounter.enemies enumerateObjectsUsingBlock:^(Enemy *enemy, NSUInteger idx, BOOL *stop) {
        enemy.scheduledSpellHandler = ^(Spell *spell, NSDate *date){
            [self.eventTimerView addSpellEvent:spell date:date];
        };
    }];
    
    [encounter start];
    
    self.encounter = encounter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_forceDraw:(id)sender
{
    //NSLog(@"needsDisplay");
    dispatch_async(dispatch_get_main_queue(), ^{
        for ( UIView *view in [[self view] subviews] )
            [view setNeedsDisplay];
//        [self.raidFramesView setNeedsDisplay];
//        [self.spellBarView setNeedsDisplay];
//        [self.castBarView setNeedsDisplay];
//        [self.enemyFrameView setNeedsDisplay];
//        [self.playerAndTargetView setNeedsDisplay];
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
