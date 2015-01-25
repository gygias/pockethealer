//
//  SpellBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SpellBarView.h"

#import "Spell.h"
#import "Player.h"
#import "UIColor+Extensions.h"

#define SPELL_HEIGHT 32
#define SPELL_WIDTH SPELL_HEIGHT
#define SPELLS_PER_ROW 5

@interface SpellBarView (PrivateProperties)
// It is not possible to add members and properties to an existing class via a category — only methods.
//@property NSMutableArray *spells;
@end

@implementation SpellBarView

@synthesize player = _player;

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        NSLog(@"%@ loaded!",self);        
    }
    return self;
}

- (void)setPlayer:(Player *)player
{
    self.spells = [[Spell castableSpellNamesForCharacter:player.character] mutableCopy];
    _player = player;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSUInteger idx = 0;
    for ( Spell *spell in self.spells )
    {
        NSString *message = nil;
        
        Entity *spellTarget = self.player.target;
        if ( ! spellTarget )
            spellTarget = self.player;
        BOOL canStartCastingSpell = [spellTarget validateSpell:spell withSource:self.player message:&message];
        
        UIImage *spellImage = spell.image;
        //if ( ! canStartCastingSpell )
        //   spellImage = [ImageFactory questionMark];
        
        NSInteger row = idx / SPELLS_PER_ROW;
        NSInteger column = idx % SPELLS_PER_ROW;
        CGRect spellRect = CGRectMake(rect.origin.x + ( SPELL_WIDTH * column ),
                                      rect.origin.y + ( SPELL_HEIGHT * row ), SPELL_WIDTH, SPELL_HEIGHT);
        //NSLog(@"drawing %@ in %f %f %f %f",spellImage,spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
        [spellImage drawInRect:spellRect];
        
        // cooldown clock
        if ( spell.nextCooldownDate )
        {
            double cooldownPercentage = -[[NSDate date] timeIntervalSinceDate:spell.nextCooldownDate] / spell.cooldown.doubleValue;
            CGFloat offset = spellRect.size.height * ( 1 - cooldownPercentage );
            //[spellImage retainCount];
            //UIBezierPath
            //NSLog(@"%@: %f",spell,cooldownPercentage);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context,[UIColor cooldownClockColor].CGColor);
            //CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
            //CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
            CGRect rectangle = CGRectMake(spellRect.origin.x,spellRect.origin.y + offset,spellRect.size.width,spellRect.size.height - offset);
            CGContextAddRect(context, rectangle);
            CGContextFillPath(context);
        }
        
        idx++;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    //NSUInteger spellIndex = ( ( [theTouch locationInView:self].x / SPELL_WIDTH );
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.spells.count )
        theSpell = self.spells[spellIdx];
    NSLog(@"you began touching %@ (%lu,%lu)",theSpell,row,column);
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    
    //NSUInteger spellIndex = ( ( [theTouch locationInView:self].x / SPELL_WIDTH );
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.spells.count )
        theSpell = self.spells[spellIdx];
    NSLog(@"you stopped touching %@ (%lu,%lu)",theSpell,row,column);
    
    if ( self.spellCastAttemptHandler )
        self.spellCastAttemptHandler(theSpell);
}

@end
