//
//  NSCache+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSCache+JEToolkit.h"


@implementation NSCache (JEToolkit)

#pragma mark - Public

- (id)objectForKeyedSubscript:(id)key {
    
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    
    [self setObject:obj forKey:key];
}


@end
