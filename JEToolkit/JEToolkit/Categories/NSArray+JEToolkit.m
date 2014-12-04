//
//  NSArray+JEToolkit.m
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

#import "NSArray+JEToolkit.h"

#import "NSMutableArray+JEToolkit.h"


@implementation NSArray (JEToolkit)

#pragma mark - Public

#pragma mark Conversion

+ (NSArray *)arrayFromValue:(id)valueOrNil {
    
    if (!valueOrNil) {
        
        return nil;
    }
    if ([valueOrNil isKindOfClass:[NSArray class]]) {
        
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSData class]]) {
        
        id JSON = [NSJSONSerialization
                   JSONObjectWithData:(NSData *)valueOrNil
                   options:kNilOptions
                   error:nil];
        if ([JSON isKindOfClass:[NSArray class]]) {
            
            return JSON;
        }
    }
    if ([valueOrNil isKindOfClass:[NSString class]]) {
        
        id JSON = [NSJSONSerialization
                   JSONObjectWithData:[(NSString *)valueOrNil dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:nil];
        if ([JSON isKindOfClass:[NSArray class]]) {
            
            return JSON;
        }
    }
    return nil;
}


#pragma mark Container Tools

- (NSArray *)shuffledArray {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self];
    [array shuffle];
    return [array copy];
}


@end
