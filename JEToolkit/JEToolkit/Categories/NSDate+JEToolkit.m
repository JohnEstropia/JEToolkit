//
//  NSDate+JEToolkit.m
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

#import "NSDate+JEToolkit.h"

#import "NSCalendar+JEToolkit.h"
#import "NSDateFormatter+JEToolkit.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


@implementation NSDate (JEToolkit)

#pragma mark - Public

#pragma mark Conversion

+ (NSDate *)dateForValue:(id)valueOrNil {
    
    if (!valueOrNil) {
        
        return nil;
    }
    if ([valueOrNil isKindOfClass:[NSDate class]]) {
        
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSNumber class]]) {
        
        return [self dateWithTimeIntervalSince1970:[(NSNumber *)valueOrNil doubleValue]];
    }
    if ([valueOrNil isKindOfClass:[NSString class]]) {
        
        return [self dateWithISO8601String:valueOrNil];
    }
    return nil;
}

+ (NSDate *)dateWithISO8601String:(NSString *)ISO8601String {
    
    JEAssertParameter([ISO8601String isKindOfClass:[NSString class]]);
    
    return [[NSDateFormatter ISO8601UTCDateFormatter] dateFromString:ISO8601String];
}

+ (NSDate *)dateWithEXIFString:(NSString *)EXIFString {
    
    JEAssertParameter([EXIFString isKindOfClass:[NSString class]]);
    
    return [[NSDateFormatter EXIFDateFormatter] dateFromString:EXIFString];
}

- (NSString *)ISO8601String {
    
    return [[NSDateFormatter ISO8601UTCDateFormatter] stringFromDate:self];
}

- (NSString *)EXIFString {
    
    return [[NSDateFormatter EXIFDateFormatter] stringFromDate:self];
}


@end
