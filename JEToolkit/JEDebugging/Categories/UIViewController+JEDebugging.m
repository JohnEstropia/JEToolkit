//
//  UIViewController+JEDebugging.m
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

#import "UIViewController+JEDebugging.h"
#import "NSObject+JEToolkit.h"
#import "JEDebugging.h"


NSString *const _JEDebugging_UIViewController_viewDidAppear = @"_JEDebugging_UIViewController_viewDidAppear";
NSString *const _JEDebugging_UIViewController_viewWillDisappear = @"_JEDebugging_UIViewController_viewWillDisappear";


@implementation UIViewController (JEDebugging)

#pragma mark - NSObject

+ (void)load {
    
    if (self != [UIViewController class]) {
        
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceMethod:@selector(viewDidAppear:)
                 withOverrideMethod:@selector(je_viewDidAppear:)];
        [self swizzleInstanceMethod:@selector(viewWillDisappear:)
                 withOverrideMethod:@selector(je_viewWillDisappear:)];
    });
}


#pragma mark - Private

- (void)je_viewDidAppear:(BOOL)animated {
    
    [self je_viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:_JEDebugging_UIViewController_viewDidAppear
     object:self];
}

- (void)je_viewWillDisappear:(BOOL)animated {
    
    [self je_viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:_JEDebugging_UIViewController_viewWillDisappear
     object:self];
}

@end
