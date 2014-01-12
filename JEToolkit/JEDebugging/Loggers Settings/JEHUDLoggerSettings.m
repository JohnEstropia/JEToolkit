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

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.logLevelMask = JELogLevelAll;
    self.logMessageHeaderMask = (JELogMessageHeaderSourceFile
                                 | JELogMessageHeaderFunction);
    self.visibleOnStart = YES;
    self.numberOfLogEntriesInMemory = 100;
    
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy->_visibleOnStart = _visibleOnStart;
    copy->_numberOfLogEntriesInMemory = _numberOfLogEntriesInMemory;
    return copy;
}


@end
