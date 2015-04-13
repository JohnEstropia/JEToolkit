//
//  JEFormulas.h
//  JEToolkit
//
//  Copyright (c) 2014 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <CoreGraphics/CoreGraphics.h>

#ifndef JEToolkit_JEFormulas_h
#define JEToolkit_JEFormulas_h

#import "JECompilerDefines.h"


#pragma mark - Arithmetic

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
NSInteger JEModulo(NSInteger number, NSInteger divisor) {
    
    return (((number % divisor) + divisor) % divisor);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEModulo(double number, double divisor) {
    
    return fmod((fmod(number, divisor) + divisor), divisor);
}


#pragma mark - Clamping Values

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEClamp(double min, double value, double max) {
    
	return MIN(max, MAX(min, value));
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
NSInteger JEClamp(NSInteger min, NSInteger value, NSInteger max) {
    
	return MIN(max, MAX(min, value));
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
NSUInteger JEClamp(NSUInteger min, NSUInteger value, NSUInteger max) {
    
	return MIN(max, MAX(min, value));
}


#pragma mark - Comparing Values

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
BOOL JEEquals(float v1, float v2) {
    
    return (fabsf(v1 - v2) < FLT_EPSILON);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
BOOL JEEquals(double v1, double v2) {
    
    return (fabs(v1 - v2) < DBL_EPSILON);
}


#pragma mark - Geometry

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleRadians(double degrees) {
    
	return (M_PI * degrees / 180.0);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleRadians(CGPoint point1, CGPoint point2, BOOL isTopToBottomCoordinateSystem) {
    
    if (isTopToBottomCoordinateSystem) {
        
        return atan2((point2.y - point1.y), (point1.x - point2.x));
    }
    return atan2((point1.y - point2.y), (point2.x - point1.x));
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleDegrees(double radians) {
    
	return (180.0 * radians / M_PI);
}

JE_STATIC_INLINE JE_CONST JE_OVERLOAD
double JEAngleDegrees(CGPoint point1, CGPoint point2, BOOL isTopToBottomCoordinateSystem) {
    
	return JEAngleDegrees(JEAngleRadians(point1, point2, isTopToBottomCoordinateSystem));
}

JE_STATIC_INLINE JE_CONST
CGPoint JEPoint(CGPoint startPoint, double angle, double distance, BOOL isTopToBottomCoordinateSystem) {
    
    if (isTopToBottomCoordinateSystem) {
        
        return (CGPoint){
            .x = (CGFloat)(startPoint.x + (sin(angle) * distance)),
            .y = (CGFloat)(startPoint.y + (cos(angle) * distance))
        };
    }
    return (CGPoint){
        .x = (CGFloat)(startPoint.x + (cos(angle) * distance)),
        .y = (CGFloat)(startPoint.y - (sin(angle) * distance))
    };
}

JE_STATIC_INLINE JE_CONST
double JEDistance(CGPoint point1, CGPoint point2) {
    
    return hypot((point1.x - point2.x), (point1.y - point2.y));
}

JE_STATIC_INLINE JE_CONST JE_CONST JE_OVERLOAD
CGPoint JEPointMidpoint(CGPoint point1, CGPoint point2) {
    
    return (CGPoint){
        .x = ((point1.x + point2.x) * 0.5f),
        .y = ((point1.y + point2.y) * 0.5f),
    };
}

JE_STATIC_INLINE JE_CONST
CGRect JERect(CGPoint midpoint, CGFloat width, CGFloat height) {
    
    return (CGRect){
        .origin.x = (midpoint.x - (width * 0.5f)),
        .origin.y = (midpoint.y - (height * 0.5f)),
        .size.width = width,
        .size.height = height
    };
}

JE_STATIC_INLINE JE_CONST JE_CONST JE_OVERLOAD
CGPoint JERectCenter(CGRect rect) {
    
	return (CGPoint){ .x = CGRectGetMidX(rect), .y = CGRectGetMidY(rect) };
}

JE_STATIC_INLINE JE_CONST
CGSize JESizeScaled(CGSize size, CGFloat scale) {
    
    return (CGSize){ .width = (size.width * scale), .height = (size.height * scale) };
}

JE_STATIC_INLINE JE_CONST
CGRect JERectAspectFill(CGRect screenRect, CGSize fromSize) {
    
	double hfactor = ((double)fromSize.width / (double)screenRect.size.width);
	double vfactor = ((double)fromSize.height / (double)screenRect.size.height);
	
	double factor = MIN(hfactor, vfactor);
	
	double newWidth = ((double)fromSize.width / factor);
	double newHeight = ((double)fromSize.height / factor);
	
	double leftOffset = (((double)screenRect.size.width - newWidth) * 0.5);
	double topOffset = (((double)screenRect.size.height - newHeight) * 0.5);
	
	return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

JE_STATIC_INLINE JE_CONST
CGRect JERectAspectFit(CGRect screenRect, CGSize fromSize) {
    
	double hfactor = ((double)fromSize.width / (double)screenRect.size.width);
	double vfactor = ((double)fromSize.height / (double)screenRect.size.height);
	
	double factor = MAX(hfactor, vfactor);
	
	double newWidth = ((double)fromSize.width / factor);
	double newHeight = ((double)fromSize.height / factor);
	
	double leftOffset = (((double)screenRect.size.width - newWidth) * 0.5);
	double topOffset = (((double)screenRect.size.height - newHeight) * 0.5);
	
	return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}


#pragma mark - Random

JE_STATIC_INLINE
int32_t JERandomInteger(int32_t min, int32_t max) {
    
    return ((int32_t)arc4random_uniform((u_int32_t)(max - min + 1)) + min);
}

JE_STATIC_INLINE
double JERandomDouble(double min, double max) {
    
    return ((((double)arc4random() / (double)(UINT32_MAX + 1)) * (max - min)) + min);
}



#endif
