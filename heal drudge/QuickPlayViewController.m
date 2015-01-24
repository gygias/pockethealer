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
        NSLog(@"%@ has targeted %@",encounter.player,enemy);
        return YES;
    };
    self.enemyFrameView.enemyTouchedHandler = enemyTouchedBlock;
    
    self.raidFramesView.raid = raid;
    self.raidFramesView.targetedPlayerBlock = ^(Entity *target){
        NSLog(@"player targeted %@",target);
        encounter.player.target = target;
    };
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_forceDraw:) userInfo:nil repeats:YES];

    
    self.spellBarView.player = aHealer;
    BOOL (^castBlock)(Spell *);
    castBlock = ^(Spell *spell) {
        
        // determine target
        BOOL doCast = NO;
        Entity *target = nil;
        if ( spell.targeted )
        {
            if ( ! encounter.player.target )
            {
                // TODO auto self target setting?
                if ( spell.isBeneficial )
                {
                    NSLog(@"auto-self casting %@",spell);
                    target = encounter.player;
                    doCast = YES;
                }
            }
            else
            {
                if ( spell.isBeneficial )
                {
                    if ( [encounter.player.target isKindOfClass:[Enemy class]] )
                    {
                        NSLog(@"can't cast beneficial spell at enemy target");
                    }
                    else
                    {
                        NSLog(@"player is casting %@ on %@",spell,encounter.player.target);
                        target = encounter.player.target;
                        doCast = YES;
                    }
                }
                else
                {
                    if ( [encounter.player.target isKindOfClass:[Player class]] )
                    {
                        NSLog(@"can't cast hostile spell on friendly");
                    }
                    else
                    {
                        NSLog(@"player is casting %@ on %@",spell,encounter.player.target);
                        target = encounter.player.target;
                        doCast = YES;
                    }
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
            doCast = [target validateSpell:spell withSource:encounter.player message:&message];
            if ( doCast )
            {
                [encounter.player castSpell:spell withTarget:target inEncounter:encounter];
                self.castBarView.castingSpell = spell;
            }
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
