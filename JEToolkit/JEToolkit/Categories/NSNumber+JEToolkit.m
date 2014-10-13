//
//  NSNumber+JEToolkit.m
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
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

#import "NSNumber+JEToolkit.h"


@implementation NSNumber (JEToolkit)

#pragma mark - Private

+ (NSNumberFormatter *)decimalFormatter {
    
	static NSNumberFormatter *formatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
	});
	return formatter;
}


#pragma mark - Public

#pragma mark Conversion

+ (NSNumber *)numberFromValue:(id)valueOrNil {
    
    if (valueOrNil) {
        
        if ([valueOrNil isKindOfClass:[NSNumber class]]) {
            
            return valueOrNil;
        }
        if ([valueOrNil isKindOfClass:[NSString class]]) {
            
            return ([[self decimalFormatter] numberFromString:valueOrNil]
                    ?: @([(NSString *)valueOrNil doubleValue]));
        }
        if ([valueOrNil isKindOfClass:[NSDate class]]) {
            
            return @([(NSDate *)valueOrNil timeIntervalSince1970]);
        }
    }
    return nil;
}

#pragma mark Displaying to user

- (NSString *)displayString {
    
    return [[NSNumber decimalFormatter] stringFromNumber:self];
}


@end
