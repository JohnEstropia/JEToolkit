//
//  JEBaseLoggerSettings.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEBaseLoggerSettings.h"

@implementation JEBaseLoggerSettings

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    typeof(self) copy = [[[self class] allocWithZone:zone] init];
    copy->_logLevelMask = _logLevelMask;
    copy->_logMessageHeaderMask = _logMessageHeaderMask;
    return copy;
}


@end
