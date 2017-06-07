//
//  NSValue+JEToolkit.m
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

#import "NSValue+JEToolkit.h"
#import <objc/runtime.h>


@interface _JEWeakValue : NSValue

@property (nonatomic, weak, readonly) id je_weakObject;

- (instancetype)initWithWeakObject:(id)weakObject;

@end


@implementation _JEWeakValue

#pragma mark - NSObject

- (instancetype)initWithWeakObject:(id)weakObject {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    _je_weakObject = weakObject;
    return self;
}


#pragma mark - NSValue

- (void)getValue:(void *)value {
    
    id __autoreleasing weakObject = self.je_weakObject;
    (*(id __autoreleasing *)value) = weakObject;
}

- (const char *)objCType {
    
    return (const char *)_C_UNDEF;
}

- (BOOL)isEqualToValue:(NSValue *)value {
    
    return [[NSValue valueWithNonretainedObject:self.je_weakObject] isEqualToValue:value];
}

@end



@implementation NSValue (JEToolkit)

#pragma mark - Public

+ (NSValue *)je_valueWithWeakObject:(id)weakObject {
    
    return [[_JEWeakValue alloc] initWithWeakObject:weakObject];
}

- (id)je_weakObjectValue {
    
    if ([self isKindOfClass:[_JEWeakValue class]])
    {
        return ((_JEWeakValue *)self).je_weakObject;
    }
    return nil;
}


@end
