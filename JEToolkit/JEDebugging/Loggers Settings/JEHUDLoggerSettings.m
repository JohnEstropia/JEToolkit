//
//  JEHUDLoggerSettings.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
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
    self.logMessageHeaderMask = (JELogMessageHeaderSourceFile
                                 | JELogMessageHeaderFunction);
    self.numberOfLogEntriesInMemory = 200;
    
    return self;
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    typeof(self) copy = [super copyWithZone:zone];
    copy->_visibleOnStart = _visibleOnStart;
    copy->_numberOfLogEntriesInMemory = _numberOfLogEntriesInMemory;
    return copy;
}


@end
