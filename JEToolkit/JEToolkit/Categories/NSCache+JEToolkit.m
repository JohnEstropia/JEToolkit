//
//  NSCache+JEToolkit.m
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

#import "NSCache+JEToolkit.h"
#import <UIKit/UIKit.h>

#import "JESafetyHelpers.h"
#import "NSObject+JEToolkit.h"


@implementation NSCache (JEToolkit)

#pragma mark - Public

- (instancetype)initWithForcedPurgingOnMemoryWarning:(BOOL)forcePurgeOnMemoryWarning {
    
    self = [self init];
    if (!self) {
        
        return nil;
    }
    
    if (!forcePurgeOnMemoryWarning) {
        
        return self;
    }
    
    JEScopeWeak(self);
    [self
     registerForNotificationsWithName:UIApplicationDidReceiveMemoryWarningNotification
     targetBlock:^(NSNotification * note) {
         
         JEScopeStrong(self);
         [self removeAllObjects];
     }];
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    
    [self setObject:obj forKey:key];
}


@end
