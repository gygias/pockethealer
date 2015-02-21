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

#define INTRINSIC_SPELL_HEIGHT ( [SpellBarView desiredSize].width )
#define INTRINSIC_SPELL_WIDTH INTRINSIC_SPELL_HEIGHT
#define SPELLS_PER_ROW 5
#define SPELL_WIDTH (( ( rect.size.height / rows ) < ( rect.size.width / SPELLS_PER_ROW ) ) ? ( rect.size.height / rows ) : ( rect.size.width / SPELLS_PER_ROW ))
#define SPELL_HEIGHT SPELL_WIDTH

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
    CGFloat spellWidth = SPELL_WIDTH;
    CGFloat spellHeight = SPELL_HEIGHT;
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
        
        NSInteger row = idx / SPELLS_PER_ROW;
        NSInteger column = idx % SPELLS_PER_ROW;
        CGRect spellRect = CGRectMake(rect.origin.x + ( spellWidth * column ),
                                      rect.origin.y + ( spellHeight * row ), spellWidth, spellHeight);
        //PHLogV(@"drawing %@ in %f %f %f %f",spellImage,spellRect.origin.x,spellRect.origin.y,spellRect.size.width,spellRect.size.height);
        
//#warning this is here due to emphasis yellow leaving traces when it stops drawing
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextAddRect(context, spellRect);
        //CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        //CGContextFillPath(context);
        // nvm drawing outside specified rect lol
        
        [spellImage drawInRect:spellRect];
                
        // disabled mask
        if ( ! canStartCastingSpell && ! invalidDueToCooldown )
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
    
    //NSUInteger spellIndex = ( ( [theTouch locationInView:self].x / SPELL_WIDTH );
    CGRect rect = self.frame;
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.player.spells.count )
        theSpell = self.player.spells[spellIdx];
    PHLogV(@"you began touching %@ (%lu,%lu)",theSpell,(unsigned long)row,(unsigned long)column);
    
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
    CGRect rect = self.frame;
    NSUInteger row = [theTouch locationInView:self].y / SPELL_HEIGHT;
    NSUInteger column = [theTouch locationInView:self].x / SPELL_WIDTH;
    NSUInteger spellIdx = ( row * SPELLS_PER_ROW ) + column;
    Spell *theSpell = nil;
    if ( spellIdx < self.player.spells.count )
        theSpell = self.player.spells[spellIdx];
    PHLogV(@"you stopped touching %@ (%lu,%lu)",theSpell,(unsigned long)row,(unsigned long)column);
    
    if ( self.spellCastAttemptHandler )
        self.spellCastAttemptHandler(theSpell);
}

@end
