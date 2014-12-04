//
//  NSDictionary+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/12/04.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "NSDictionary+JEToolkit.h"

@implementation NSDictionary (JEToolkit)

+ (NSDictionary *)dictionaryFromValue:(id)valueOrNil {
    
    if (!valueOrNil) {
        
        return nil;
    }
    if ([valueOrNil isKindOfClass:[NSDictionary class]]) {
        
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSData class]]) {
        
        id JSON = [NSJSONSerialization
                   JSONObjectWithData:(NSData *)valueOrNil
                   options:kNilOptions
                   error:nil];
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            
            return JSON;
        }
    }
    if ([valueOrNil isKindOfClass:[NSString class]]) {
        
        id JSON = [NSJSONSerialization
                   JSONObjectWithData:[(NSString *)valueOrNil dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:nil];
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            
            return JSON;
        }
    }
    return nil;
}

@end
