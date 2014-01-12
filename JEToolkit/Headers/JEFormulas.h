//
//  JEFormulas.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/05.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#ifndef JEToolkit_JEFormulas_h
#define JEToolkit_JEFormulas_h

#import "JECompilerDefines.h"


#pragma mark - Geometry

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleRadians(double degrees)
{
	return (M_PI * degrees / 180.0);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleRadians(CGPoint point1, CGPoint point2)
{
	CGFloat height = (point2.y - point1.y);
	CGFloat width = (point1.x - point2.x);
	return atan(height / width);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleDegrees(double radians)
{
	return (180.0 * radians / M_PI);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleDegrees(CGPoint point1, CGPoint point2)
{
	return JEAngleDegrees(JEAngleRadians(point1, point2));
}

JE_STATIC_INLINE JE_CONST
CGPoint JERectCenter(CGRect rect)
{
	return (CGPoint){ .x = CGRectGetMidX(rect), .y = CGRectGetMidY(rect) };
}

JE_STATIC_INLINE JE_CONST
CGSize JESizeScaled(CGSize size, CGFloat scale)
{
    return (CGSize){ .width = (size.width * scale), .height = (size.height * scale) };
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEClamp(double min, double value, double max)
{
	return MIN(max, MAX(min, value));
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
NSInteger JEClamp(NSInteger min, NSInteger value, NSInteger max)
{
	return MIN(max, MAX(min, value));
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
NSUInteger JEClamp(NSUInteger min, NSUInteger value, NSUInteger max)
{
	return MIN(max, MAX(min, value));
}



#endif
