//
//  JEWeakCache.m
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

#import "JEWeakCache.h"


@interface JEWeakCache ()

@property (nonatomic, strong, readonly) NSMapTable *mapTable;
@property (nonatomic, strong, readonly) dispatch_queue_t barrierQueue;

@end


@implementation JEWeakCache

#pragma mark - NSObject

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    _mapTable = [NSMapTable strongToWeakObjectsMapTable];
    _barrierQueue = dispatch_queue_create("com.JEToolkit.JEWeakCache.barrierQueue",
                                          DISPATCH_QUEUE_CONCURRENT);
    
    return self;
}

#pragma mark - Public

- (id)objectForKey:(id)key {
    
    id __block object;
    typeof(self) __weak weakSelf;
    dispatch_barrier_sync(self.barrierQueue, ^{
        
        typeof(self) self = weakSelf;
        object = [self.mapTable objectForKey:key];
        
    });
    return object;
}

- (void)setObject:(id)obj forKey:(id)key {
    
    typeof(self) __weak weakSelf;
    dispatch_barrier_async(self.barrierQueue, ^{
        
        typeof(self) self = weakSelf;
        if (obj) {
            
            [self.mapTable setObject:obj forKey:key];
        }
        else {
            
            [self.mapTable removeObjectForKey:key];
        }
        
    });
}

- (void)removeObjectForKey:(id)key {
    
    typeof(self) __weak weakSelf;
    dispatch_barrier_async(self.barrierQueue, ^{
        
        typeof(self) self = weakSelf;
        [self.mapTable removeObjectForKey:key];
        
    });
}

- (id)objectForKeyedSubscript:(id)key {
    
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    
    [self setObject:obj forKey:key];
}

@end
