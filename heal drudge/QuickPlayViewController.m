//
//  QuickPlayViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "QuickPlayViewController.h"

#import "Encounter.h"

@interface QuickPlayViewController ()

@end

@implementation QuickPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Player *gygias = nil;
    Raid *raid = [Raid randomRaidWithGygiasTheDiscPriest:&gygias];
    
    /*__block*/ Player *aHealer = gygias;
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
    
    Enemy *enemy = [Enemy randomEnemy];
    self.enemyFrameView.enemy = enemy;
    
    Encounter *encounter = [Encounter new];
    encounter.encounterUpdatedHandler = ^(Encounter *encounter){
        [self _forceDraw:self];
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
    self.raidFramesView.targetedPlayerBlock = ^(Entity *target){
        encounter.player.target = target;
        self.playerAndTargetView.target = target;
        NSLog(@"player targeted %@",target);
    };
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_forceDraw:) userInfo:nil repeats:YES];

    self.playerAndTargetView.player = aHealer;
    
    self.spellBarView.player = aHealer;
    BOOL (^castBlock)(Spell *);
    castBlock = ^(Spell *spell) {
        
        // determine target
        BOOL doCast = NO;
        Entity *target = nil;
        if ( spell.nextCooldownDate )
        {
            NSLog(@"%@ can't cast %@ because it is on cooldown",encounter.player,spell);
        }
        else if ( spell.targeted )
        {
            if ( encounter.player.target )
            {
                target = encounter.player.target;
                doCast = YES;
            }
            else
            {
                if ( spell.isBeneficial )
                {
                    NSLog(@"auto-self casting %@",spell);
                    target = encounter.player;
                    doCast = YES;
                }
            }
        }
        else
        {
            target = encounter.player;
            doCast = YES;
        }
        
        if ( doCast )
        {
            NSString *message = nil;
            doCast = [target validateTargetOfSpell:spell withSource:encounter.player message:&message];
            if ( doCast )
            {
                [encounter.player castSpell:spell withTarget:target inEncounter:encounter];
                self.castBarView.castingSpell = spell;
            }
            else
                NSLog(@"%@'s %@ failed: %@",encounter.player,spell,message);
        }
        
        return doCast;
    };
    
    self.spellBarView.spellCastAttemptHandler = castBlock;
    
    [self _forceDraw:self];
    
    [encounter start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_forceDraw:(id)sender
{
    //NSLog(@"needsDisplay");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.raidFramesView setNeedsDisplay];
        [self.spellBarView setNeedsDisplay];
        [self.castBarView setNeedsDisplay];
        [self.enemyFrameView setNeedsDisplay];
        [self.playerAndTargetView setNeedsDisplay];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
