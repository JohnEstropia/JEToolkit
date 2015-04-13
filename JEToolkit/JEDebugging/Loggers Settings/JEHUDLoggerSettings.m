//
//  JEHUDLoggerSettings.m
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

#import "JEHUDLoggerSettings.h"

@implementation JEHUDLoggerSettings

#pragma mark - NSObject

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
#if DEBUG
    self.logLevelMask = JELogLevelAll;
#else
    self.logLevelMask = JELogLevelNone;
#endif
    
    self.visibleOnStart = NO;
    self.buttonOffsetOnStart = 1.0;
    self.logMessageHeaderMask = (JELogMessageHeaderSourceFile
                                 | JELogMessageHeaderFunction);
    self.numberOfLogEntriesInMemory = 200;
    
    return self;
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    typeof(self) copy = [super copyWithZone:zone];
    copy->_visibleOnStart = _visibleOnStart;
    copy->_buttonOffsetOnStart = _buttonOffsetOnStart;
    copy->_numberOfLogEntriesInMemory = _numberOfLogEntriesInMemory;
    return copy;
}


#pragma mark - JEBaseLoggerSettings

@dynamic logLevelMask;
@dynamic logMessageHeaderMask;


@end
