//
//  JEWeakCache.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/02/02.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JEWeakCache : NSObject

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)obj forKeyedSubscript:(id)key;

- (void)removeObjectForKey:(id)key;

@end
