//
//  JEConsoleLoggerSettings.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEConsoleLoggerSettings.h"

@implementation JEConsoleLoggerSettings

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.logLevelMask = JELogLevelAll;
    self.logMessageHeaderMask = (JELogMessageHeaderQueue
                                 | JELogMessageHeaderSourceFile
                                 | JELogMessageHeaderFunction);
    return self;
}

@end
