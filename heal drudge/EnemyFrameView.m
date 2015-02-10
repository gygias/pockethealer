//
//  EnemyFrameView.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "EnemyFrameView.h"
#import "Enemy.h"

@implementation EnemyFrameView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

@synthesize enemy = _enemy;

- (void)setEnemy:(Enemy *)enemy
{
    [self invalidateIntrinsicContentSize];
    _enemy = enemy;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(100, 50);
}

#define ENEMY_FRAME_BORDER_INSET 1

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.enemy.name drawInRect:rect withAttributes:attributes];
    
    CGSize nameSize = [self.enemy.name sizeWithAttributes:attributes];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGRect borderRect = CGRectMake(rect.origin.x + ENEMY_FRAME_BORDER_INSET, rect.origin.y + nameSize.height + ENEMY_FRAME_BORDER_INSET, rect.size.width - ENEMY_FRAME_BORDER_INSET, rect.size.height - nameSize.height - ENEMY_FRAME_BORDER_INSET);
//    CGContextAddRect(context, borderRect);
//    CGContextSetStrokeColorWithColor(context,
//                                     [UIColor grayColor].CGColor);
//    CGContextFillPath(context);
    
    double healthPercentage = self.enemy.currentHealthPercentage.doubleValue;
    
    CGFloat lineWidth = 1;
    CGContextSetLineWidth(context, 1);
    
    CGRect healthBorderRect = CGRectMake(rect.origin.x, rect.origin.y + nameSize.height, rect.size.width, rect.size.height - nameSize.height - lineWidth);
    CGRect healthRect = CGRectMake(healthBorderRect.origin.x, healthBorderRect.origin.y, healthBorderRect.size.width * healthPercentage, healthBorderRect.size.height);
    
    CGContextAddRect(context, healthRect);
    CGContextSetFillColorWithColor(context,
                                     [UIColor redColor].CGColor);
    CGContextFillPath(context);
    CGContextAddRect(context, healthBorderRect);
    CGContextSetStrokeColorWithColor(context,
                                   [UIColor grayColor].CGColor);
    
    NSString *healthPercentageString = [NSString stringWithFormat:@"%0.0f%%",healthPercentage * 100];
    CGFloat healthBorderRectCenterX = ( healthBorderRect.origin.x + healthBorderRect.size.width ) / 2;
    CGFloat healthBorderRectCenterY = ( healthBorderRect.origin.y + healthBorderRect.size.height ) / 2;
    CGRect healthPercentageStringRect = CGRectMake( healthBorderRectCenterX,
                                                    healthBorderRectCenterY,
                                                    healthBorderRect.size.width - ( healthBorderRectCenterX - healthBorderRect.origin.x ),
                                                    healthBorderRect.size.height - ( healthBorderRectCenterY - healthBorderRect.origin.y ) );
    [healthPercentageString drawInRect:healthPercentageStringRect withAttributes:attributes];
    
    CGContextStrokePath(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event touchesForView:self];
    UITouch *theTouch = [myTouches anyObject]; // XXX
    if ( theTouch )
    {
        //PHLogV(@"you touched %@",self.enemy);
    
        if ( self.enemyTouchedHandler )
            self.enemyTouchedHandler(self.enemy);
    }
}

@end
