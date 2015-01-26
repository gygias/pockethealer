//
//  EnemyFrameView.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EnemyFrameView.h"

#import "Enemy.h"

@implementation EnemyFrameView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#define ENEMY_FRAME_BORDER_INSET 1

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.enemy.name drawInRect:rect withAttributes:attributes];
    
    CGSize nameSize = [self.enemy.name sizeWithAttributes:nil];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGRect borderRect = CGRectMake(rect.origin.x + ENEMY_FRAME_BORDER_INSET, rect.origin.y + nameSize.height + ENEMY_FRAME_BORDER_INSET, rect.size.width - ENEMY_FRAME_BORDER_INSET, rect.size.height - nameSize.height - ENEMY_FRAME_BORDER_INSET);
//    CGContextAddRect(context, borderRect);
//    CGContextSetStrokeColorWithColor(context,
//                                     [UIColor grayColor].CGColor);
//    CGContextFillPath(context);
    
    double healthPercentage = self.enemy.currentHealth.doubleValue / self.enemy.health.doubleValue;
    CGRect healthRect = CGRectMake(rect.origin.x, rect.origin.y + nameSize.height, rect.size.width * healthPercentage, rect.size.height - nameSize.height);
    
    CGContextAddRect(context, healthRect);
    CGContextSetFillColorWithColor(context,
                                     [UIColor redColor].CGColor);
    CGContextFillPath(context);
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
        NSLog(@"you touched %@",self.enemy);
    
        if ( self.enemyTouchedHandler )
            self.enemyTouchedHandler(self.enemy);
    }
}

@end
