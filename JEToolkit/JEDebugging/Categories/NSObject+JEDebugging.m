//
//  NSObject+JEDebugging.m
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

#import "NSObject+JEDebugging.h"

#import "NSString+JEToolkit.h"


static NSString *const JEDebuggingEmptyDescription = @"<No Objective-C description available>";


@implementation NSObject (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    return [self loggingDescriptionIncludeClass:YES includeAddress:YES];
}


#pragma mark - Public

#pragma mark Logging

- (NSString *)loggingDescription {
    
    if ([self isKindOfClass:NSClassFromString(@"NSBlock")]) {
        
        NSMutableString *blockDescription = [NSMutableString stringWithString:
                                             [[NSValue value:&self withObjCType:@encode(typeof(^{}))]
                                              loggingDescriptionIncludeClass:NO
                                              includeAddress:NO]];
        
        NSString *classString = [NSString stringWithFormat:@"(%@ *) ", [self class]];
        if ([blockDescription hasPrefix:classString]) {
            
            [blockDescription deleteCharactersInRange:[classString range]];
        }
        
        NSString *addressString = [NSString stringWithFormat:@"<%p> ", self];
        if ([blockDescription hasPrefix:addressString]) {
            
            [blockDescription deleteCharactersInRange:[addressString range]];
        }
        
        return blockDescription;
    }
    
    return ([self description] ?: JEDebuggingEmptyDescription);
}

- (NSString *)loggingDescriptionIncludeClass:(BOOL)includeClass
                              includeAddress:(BOOL)includeAddress {
    
    NSMutableString *description = [NSMutableString string];
    @autoreleasepool {
        
        if (includeClass) {
            
            [description appendFormat:@"(%@ *) ", [self class]];
        }
        if (includeAddress) {
            
            [description appendFormat:@"<%p> ", self];
        }
        [description appendString:([self loggingDescription] ?: JEDebuggingEmptyDescription)];
        
    }
    return description;
}


@end
