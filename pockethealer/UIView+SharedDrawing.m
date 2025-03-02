//
//  UIView+SharedDrawing.m
//  pockethealer
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "UIView+SharedDrawing.h"

@implementation UIView (SharedDrawing)

- (void)drawCooldownClockInRect:(CGRect)rect withPercentage:(double)percentage
{
    //CGFloat offset = spellRect.size.height * ( 1 - cooldownPercentage );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ( percentage < 0 || percentage > 1 )
    {
        //[NSException raise:@"PercentageOutOfBoundsException" format:@"%@",self.entity];
        //PHLogV(@"Bug: %@: Cooldown clock percentage out of bounds, will correct: %0.5f",self,percentage);
        percentage = percentage - ((int)percentage);
    }
    
    double cooldownInDegress = percentage * 360.0;
    double theta = ( cooldownInDegress + 90 );
    if ( theta > 360 )
        theta -= 360;
    double thetaRadians = theta * ( M_PI / 180 );
    CGPoint unitPoint = CGPointMake(cos(thetaRadians), sin(thetaRadians));
    //PHLogV(@"%0.2f'->%0.2f' (%0.2f) (%0.1f,%0.1f)",cooldownInDegress,theta,thetaRadians,unitPoint.x,unitPoint.y);
    
    CGContextSetFillColorWithColor(context,[UIColor cooldownClockColor].CGColor);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + ( rect.size.width / 2 ), rect.origin.y);
    CGPoint midPoint = CGPointMake(rect.origin.x + ( rect.size.width / 2 ), rect.origin.y + ( rect.size.height / 2 ));
    CGContextAddLineToPoint(context, midPoint.x, midPoint.y);
    
    CGPoint unitPointScaled = CGPointMake(midPoint.x + ( unitPoint.x * ( rect.size.width / 2 ) ), midPoint.y - ( unitPoint.y * ( rect.size.height / 2 )));
    CGFloat slope = ( unitPointScaled.y - midPoint.y ) / ( unitPointScaled.x - midPoint.x );
    CGPoint endPoint = {0};
    // y = mx + b
    // y intercept  b = y - mx
    //              b =
    //              x = ( y - b ) / m
    CGFloat b = midPoint.y - slope * midPoint.x;
    double rotatedByDegrees = ( 360 - cooldownInDegress );
    CGFloat x = 0, y = 0;
    if ( rotatedByDegrees > 315 || rotatedByDegrees <= 45 ) // solve for x along the top
    {
        x = ( rect.origin.y - b ) / slope;
        endPoint = CGPointMake(x,rect.origin.y);
    }
    else if ( rotatedByDegrees > 45 && rotatedByDegrees <= 135 ) // solve for y along the right
    {
        y = slope * ( rect.origin.x + rect.size.width ) + b;
        endPoint = CGPointMake( rect.origin.x + rect.size.width, y );
    }
    else if ( rotatedByDegrees > 135 && rotatedByDegrees <= 225 ) // solve for x along the bottom
    {
        x = ( ( rect.origin.y + rect.size.height ) - b ) / slope;
        endPoint = CGPointMake( x, rect.origin.y + rect.size.height );
    }
    else // solve for y along the left
    {
        y = slope * ( rect.origin.x ) + b;
        endPoint = CGPointMake( rect.origin.x, y );
    }
    
    // TODO SIGABRT Assertion failed: (CGFloatIsValid(x) && CGFloatIsValid(y)), function void CGPathAddLineToPoint(CGMutablePathRef, const CGAffineTransform *, CGFloat, CGFloat), file Paths/CGPath.cc, line 265. \
    x	CGFloat	3.0858984037676233E-314	3.0858984037676233E-314 \
    y	CGFloat	3.0888696197011086E-314	3.0888696197011086E-314 \
    rect	CGRect	origin=(x=0, y=90) size=(width=45, height=45) \
    unitPoint	CGPoint	(x=NaN, y=0) \
    midPoint	CGPoint	(x=3.0852801497810434E-314, y=NaN)
    if ( isnan(endPoint.x) || isnan(endPoint.y) )
    {
        PHLogV(@"cooldown clock nan bug happened");
        return;
    }
    
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y); // the mystery point
    if ( rotatedByDegrees <= 45 ) // TOP RIGHT
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    if ( rotatedByDegrees <= 135 ) // BOTTOM RIGHT
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    if ( rotatedByDegrees <= 225 ) // BOTTOM LEFT
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    if ( rotatedByDegrees <= 315 ) // TOP LEFT
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    
    //if ( theta >= 180 && theta <= 90 )
    //    CGContextAddLineToPoint(context, spellRect.origin.x, spellRect.origin.y);
    //CGRect rectangle = CGRectMake(spellRect.origin.x,spellRect.origin.y + offset,spellRect.size.width,spellRect.size.height - offset);
    //CGContextAddRect(context, rectangle);
    CGContextFillPath(context);
}

- (void)drawRoundedRectangleInRect:(CGRect)rect color:(UIColor *)color radius:(CGFloat)radius
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, M_PI, 3 * M_PI_2, NO);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 3 * M_PI_2, 2 * M_PI, NO);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, 0, M_PI_2, NO);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2, M_PI, NO);
    CGContextFillPath(context);
}

- (void)drawRadialGradientFromPoint:(CGPoint)startPoint
                        startRadius:(CGFloat)startRadius
                         startColor:(UIColor *)startColor
                           endPoint:(CGPoint)endPoint
                          endRadius:(CGFloat)endRadius
                           endColor:(UIColor *)endColor
                       clippingPath:(CGPathRef)clippingPath
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    BOOL willClip = ( clippingPath != nil );
    
    if ( willClip )
        CGContextSaveGState(context);
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat components[8] = { 0.0, 0.0, 0.0, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0 }; // End color
    NSArray *theColors = @[ startColor, endColor ];
    NSUInteger colorsIdx = 0;
    NSUInteger nRGBComponents = 4;
    
    for ( ; colorsIdx < theColors.count; colorsIdx++ )
    {
        UIColor *uiColor = theColors[colorsIdx];
        CGFloat red, green, blue, alpha;
        [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
        components[0 + nRGBComponents * colorsIdx] = red;
        components[1 + nRGBComponents * colorsIdx] = green;
        components[2 + nRGBComponents * colorsIdx] = blue;
        components[3 + nRGBComponents * colorsIdx] = alpha;
    }
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                                    locations, num_locations);
    if ( willClip )
    {
        CGContextAddPath(context, clippingPath);
        if(!CGContextIsPathEmpty(context))
            CGContextClip(context); // TODO ??
    }
    
    CGContextDrawRadialGradient(context,
                                myGradient,
                                startPoint,
                                startRadius,
                                endPoint,
                                endRadius,
                                0);
    
    if ( willClip )
        CGContextRestoreGState(context);
}

- (void)_componentsWithStart:(UIColor *)startColor
                         end:(UIColor *)endColor
                    outSpace:(CGColorSpaceRef *)outSpace
                outLocations:(CGFloat **)outLocations
               outNLocations:(size_t *)outNLocations
               outComponents:(CGFloat **)outComponents
{
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat components[8] = { 0.0, 0.0, 0.0, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0 }; // End color
    NSArray *theColors = @[ startColor, endColor ];
    NSUInteger colorsIdx = 0;
    NSUInteger nRGBComponents = 4;
    
    for ( ; colorsIdx < theColors.count; colorsIdx++ )
    {
        UIColor *uiColor = theColors[colorsIdx];
        CGFloat red, green, blue, alpha;
        [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
        components[0 + nRGBComponents * colorsIdx] = red;
        components[1 + nRGBComponents * colorsIdx] = green;
        components[2 + nRGBComponents * colorsIdx] = blue;
        components[3 + nRGBComponents * colorsIdx] = alpha;
    }
    
    if ( outSpace )
        *outSpace = myColorspace;
    if ( outLocations )
        *outLocations = locations;
    if ( outNLocations )
        *outNLocations = num_locations;
    if ( outComponents )
        *outComponents = components;
}

- (void)drawGradientFromPoint:(CGPoint)pointA
                      toPoint:(CGPoint)pointB
                   startColor:(UIColor *)startColor
                     endColor:(UIColor *)endColor
                 clippingPath:(CGPathRef)clippingPath
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    BOOL willClip = ( clippingPath != nil );
    
    if ( willClip )
        CGContextSaveGState(context);
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat components[8] = { 0.0, 0.0, 0.0, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0 }; // End color
    NSArray *theColors = @[ startColor, endColor ];
    NSUInteger colorsIdx = 0;
    NSUInteger nRGBComponents = 4;
    
    for ( ; colorsIdx < theColors.count; colorsIdx++ )
    {
        UIColor *uiColor = theColors[colorsIdx];
        CGFloat red, green, blue, alpha;
        [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
        components[0 + nRGBComponents * colorsIdx] = red;
        components[1 + nRGBComponents * colorsIdx] = green;
        components[2 + nRGBComponents * colorsIdx] = blue;
        components[3 + nRGBComponents * colorsIdx] = alpha;
    }
    
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                                    locations, num_locations);
    if ( willClip )
    {
        CGContextAddPath(context, clippingPath);
        if(!CGContextIsPathEmpty(context))
            CGContextClip(context); // TODO ??
    }
    
    CGContextDrawLinearGradient(context,
                                myGradient,
                                pointA,
                                pointB,
                                0);
    if ( willClip )
        CGContextRestoreGState(context);
}

@end
