//
//  SpellBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SpellBarView.h"

#import "Spell.h"
#import "Entity.h"
#import "Encounter.h"

#define INTRINSIC_SPELL_HEIGHT ( [SpellBarView desiredSize].width )
#define INTRINSIC_SPELL_WIDTH INTRINSIC_SPELL_HEIGHT
#define SPELLS_PER_ROW 5
#define CURRENT_SPELL_WIDTH (( ( _lastRect.size.height / rows ) < ( _lastRect.size.width / SPELLS_PER_ROW ) ) ? ( _lastRect.size.height / rows ) : ( _lastRect.size.width / SPELLS_PER_ROW ))
#define CURRENT_SPELL_HEIGHT CURRENT_SPELL_WIDTH

@interface SpellBarView (PrivateProperties)
// It is not possible to add members and properties to an existing class via a category — only methods.
//@property NSMutableArray *spells;
@end

@implementation SpellBarView

@synthesize player = _player;

- (void)setPlayer:(Entity *)player
{
    // only reason this was overridden
    //self.spells = [[Spell castableSpellsForCharacter:player] mutableCopy];
    [self invalidateIntrinsicContentSize];
    _player = player;
    rows = ( self.player.spells.count <= 5 ? 1 : ( self.player.spells.count / SPELLS_PER_ROW + 1 ) );
    columns = SPELLS_PER_ROW;
    
    self.gestureRecognizers = @[ [self _startDragRecognizer] ];
}

- (UIGestureRecognizer *)_startDragRecognizer
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPress:)];
    recognizer.minimumPressDuration = 1;
    return recognizer;
}

- (void)_longPress:(UIGestureRecognizer *)recognizer
{
    CGPoint myPoint = [recognizer locationInView:self];
    CGPoint theirPoint = [recognizer locationInView:self.superview.superview];
    CGPoint dragShiftedUpLeftByOneThumb = CGPointMake(theirPoint.x - CURRENT_SPELL_WIDTH, theirPoint.y - CURRENT_SPELL_HEIGHT);
    
    if ( recognizer.state == UIGestureRecognizerStateBegan )
    {
        self.currentDragSpell = [self _spellAtPoint:myPoint];
        if ( self.currentDragSpell )
        {
            PHLogV(@"PICKED UP: %@: %@: %@",self.currentDragSpell,recognizer,PointString(theirPoint));
            self.dragBeganHandler(self.currentDragSpell,dragShiftedUpLeftByOneThumb);
            self.depressedSpell = nil;
        }
    }
    else if ( recognizer.state == UIGestureRecognizerStateChanged )
    {
        //PHLogV(@"DRAGGING: %@: %@: %@",self.currentDragSpell,recognizer,PointString(theirPoint));
        self.dragUpdatedHandler(self.currentDragSpell,dragShiftedUpLeftByOneThumb);
    }
    else if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        Spell *replacedSpell = [self _spellAtPoint:myPoint];
        __block BOOL replaced = NO;
        if ( replacedSpell )
        {
            Spell *replacingSpell = self.currentDragSpell;
            PHLogV(@"DROPPED: %@: %@ @ %@/%@ in %@",replacingSpell,replacedSpell,PointString(myPoint),PointString(theirPoint),RectString(self.frame));
            //PHLogV(@"MY FUCKING FRAME IS %@",RectString(self.frame));
            
            if ( myPoint.x >= 0 && myPoint.x <= ( self.frame.origin.x + self.frame.size.width ) &&
                myPoint.y >= 0 && myPoint.y <= ( self.frame.origin.y + self.frame.size.height ) )
            {
                if ( replacedSpell != replacingSpell )
                {
                    replaced = YES;
                    dispatch_async(self.player.encounter.encounterQueue, ^{
                        [self.player replaceSpell:replacedSpell withSpell:replacingSpell persist:YES];
                    });
                }
            }
        }
        self.dragEndedHandler( replaced ? nil : self.currentDragSpell,dragShiftedUpLeftByOneThumb );
        self.currentDragSpell = nil;
    }
    else
    {
        self.currentDragSpell = nil;
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(rows * INTRINSIC_SPELL_WIDTH, INTRINSIC_SPELL_HEIGHT * columns);
}

CGSize sSpellBarSpellSize = {0,0};
+ (CGSize)desiredSize
{
    if ( sSpellBarSpellSize.width == 0 )
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        if ( screenRect.size.width > screenRect.size.height )
        {
            screenWidth = screenRect.size.height;
            screenHeight = screenRect.size.width;
        }
        // iphone 6 667/375
        //  70 / 375 = 0.18666666666667
        //  40 / 667 = 0.0599700149925
        sSpellBarSpellSize = CGSizeMake(0.10 * screenWidth, 0.10 * screenHeight);
    }
    return sSpellBarSpellSize;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _lastRect = rect;
    [self.player.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        
        NSString *message = nil;
        
        Entity *spellTarget = self.player.target;
        if ( ! spellTarget )
            spellTarget = self.player;
        else if ( ! spell.targeted )
            spellTarget = self.player;
        BOOL invalidDueToCooldown = NO;
        BOOL canStartCastingSpell = [self.player validateSpell:spell asSource:YES otherEntity:spellTarget message:&message invalidDueToCooldown:&invalidDueToCooldown];
        if ( canStartCastingSpell && spellTarget != self.player )
            canStartCastingSpell = [spellTarget validateSpell:spell asSource:NO otherEntity:self.player message:&message invalidDueToCooldown:&invalidDueToCooldown];
        
        UIImage *spellImage = spell.image;
        //if ( ! canStartCastingSpell )
        //   spellImage = [ImageFactory questionMark];
        //PHLogV(@"drawing %@ in %f %f %f %f",spellImage,spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
        
//#warning this is here due to emphasis yellow leaving traces when it stops drawing
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextAddRect(context, spellRect);
        //CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        //CGContextFillPath(context);
        // nvm drawing outside specified rect lol
        
        CGRect spellRect = [self _rectForSpell:spell];
        [spellImage drawInRect:spellRect];
                
        // disabled mask
        if ( ( ! canStartCastingSpell && ! invalidDueToCooldown ) || spell == self.depressedSpell )
        {
            CGContextSetFillColorWithColor(context,[UIColor disabledSpellColor].CGColor);
            CGRect rectangle = CGRectMake(spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
            CGContextAddRect(context, rectangle);
            CGContextFillPath(context);
        }
        
        if ( spell.isEmphasized )
        {
            [self _drawEmphasisInRect:spellRect spell:spell];
        }
        
        //if ( spell == self.depressedSpell )
        //    return;
        
        // cooldown clock
        if ( spell.nextCooldownDate )
        {
            double cooldownPercentage = -[[NSDate date] timeIntervalSinceDateMinusPauseTime:spell.nextCooldownDate] / spell.cooldown.doubleValue;
            [self drawCooldownClockInRect:spellRect withPercentage:cooldownPercentage];
        }
        else if ( self.player.nextGlobalCooldownDate && self.player.currentGlobalCooldownDuration > 0 )
        {
            double gcdPercentage = -[[NSDate date] timeIntervalSinceDateMinusPauseTime:self.player.nextGlobalCooldownDate] / self.player.currentGlobalCooldownDuration;
            [self drawCooldownClockInRect:spellRect withPercentage:gcdPercentage];
        }
        
        idx++;
//#warning crashing here EXC_BAD_ACCESS objc_release (mystery object) when casting lay on hands
        // fixed http://stackoverflow.com/questions/8814718/handling-pointer-to-pointer-ownership-issues-in-arc
    }];
}

static CGFloat const kDashedBorderWidth     = (4.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);
static NSUInteger const kTimeToMoveOneLengthTenthsOfASecond   = (4);

- (void)_drawEmphasisInRect:(CGRect)rect spell:(Spell *)spell
{
    if ( ! _emphasisReferenceDate )
        _emphasisReferenceDate = [NSDate date];
    NSDate *emphasisEndDate = spell.emphasisStopDate;
    if ( ! emphasisEndDate )
        return;
    
    NSDate *now = [NSDate date];
    NSTimeInterval timeRemaining = -[now timeIntervalSinceDateMinusPauseTime:emphasisEndDate];
    if ( timeRemaining <= 0 )
        return;
    
    NSUInteger modTenthsOfASecond = (NSUInteger)( timeRemaining * 10 ) % 10;
    
    CGFloat kDashedPhase           = (((double)modTenthsOfASecond / (double)kTimeToMoveOneLengthTenthsOfASecond) * kDashedLinesLength[0]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, kDashedBorderWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    
    CGRect emphasisRect = CGRectMake(rect.origin.x + kDashedBorderWidth / 2,
                                     rect.origin.y + kDashedBorderWidth / 2,
                                     rect.size.width - ( kDashedBorderWidth ),
                                     rect.size.height - ( kDashedBorderWidth ));
    CGContextAddRect(context, emphasisRect);
    CGContextStrokePath(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    Spell *theSpell = [self _spellAtPoint:[theTouch locationInView:self]];
    //PHLogV(@"you began touching %@",theSpell);
    self.depressedSpell = theSpell;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    Spell *theSpell = [self _spellAtPoint:[theTouch locationInView:self]];
    if ( theSpell != self.depressedSpell )
        self.depressedSpell = theSpell;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    Spell *theSpell = [self _spellAtPoint:[theTouch locationInView:self]];
    //PHLogV(@"you stopped touching %@",theSpell);
    
    if ( ! self.currentDragSpell )
    {
        if ( self.spellCastAttemptHandler )
            self.spellCastAttemptHandler(theSpell);
    }
    
    self.depressedSpell = nil;
}

- (Spell *)_spellAtPoint:(CGPoint)point
{
    NSUInteger row = point.y / CURRENT_SPELL_HEIGHT;
    NSUInteger column = point.x / CURRENT_SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.player.spells.count )
        theSpell = self.player.spells[spellIdx];
    return theSpell;
}

- (CGRect)rectForSpell:(Spell *)spell
{
    if ( ! [self.player.spells containsObject:spell] )
    {
        PHLogV(@"*** %@ has no %@ spell",self.player,spell);
        return CGRectMake(0,0,0,0);
    }
    
    return [self _rectForSpell:spell];
}

- (CGRect)_rectForSpell:(Spell *)spell
{
    // TODO this is probably not safe, spell order is mutated on the encounter queue, this method called on the main queue
    NSUInteger idx = [self.player.spells indexOfObject:spell];
    
    NSInteger row = idx / SPELLS_PER_ROW;
    NSInteger column = idx % SPELLS_PER_ROW;
    CGFloat spellWidth = CURRENT_SPELL_WIDTH;
    CGFloat spellHeight = CURRENT_SPELL_HEIGHT;
    CGRect spellRect = CGRectMake(_lastRect.origin.x + ( spellWidth * column ),
                                  _lastRect.origin.y + ( spellHeight * row ), spellWidth, spellHeight);
    
    return spellRect;
}

@end
