//
//  NSObject+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSObject+JEDebugging.h"


static NSString *const JEDebuggingEmptyDescription = @"<No Objective-C description available>";


@implementation NSObject (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    return [self loggingDescriptionIncludeClass:YES includeAddress:YES];
}


#pragma mark - Public

#pragma mark Logging

- (NSString *)loggingDescription {
    
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
