//
//  Conveniences.m
//  pockethealer
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Conveniences.h"

NSString * PointString(CGPoint point)
{
    return [NSString stringWithFormat:@"(x=%0.2f, y=%0.2f)",point.x,point.y];
}

NSString * RectString(CGRect rect)
{
    return [NSString stringWithFormat:@"%@[w=%0.2f,h=%0.2f]",PointString(rect.origin),rect.size.width,rect.size.height];
}

CGPoint CGRectGetMid(CGRect rect)
{
    return CGPointMake( rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2 );
}
