//
//  JEFileLoggerSettings.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEFileLoggerSettings.h"

#import "NSString+JEToolkit.h"


@implementation JEFileLoggerSettings

#pragma mark - NSObject

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    self.logLevelMask = (JELogLevelNotice | JELogLevelAlert);
    self.logMessageHeaderMask = JELogMessageHeaderAll;
    
    self.fileLogsDirectoryURL = [[NSURL alloc]
                                 initFileURLWithPath:[[NSString cachesDirectory] stringByAppendingPathComponent:@"Logs"]
                                 isDirectory:YES];
    self.numberOfBytesInMemoryBeforeWritingToFile = (1024 * 100); // 100KB
    self.numberOfDaysBeforeDeletingFile = 7;
    
    return self;
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    typeof(self) copy = [super copyWithZone:zone];
    copy->_fileLogsDirectoryURL = [_fileLogsDirectoryURL copyWithZone:zone];
    copy->_numberOfBytesInMemoryBeforeWritingToFile = _numberOfBytesInMemoryBeforeWritingToFile;
    copy->_numberOfDaysBeforeDeletingFile = _numberOfDaysBeforeDeletingFile;
    return copy;
}



@end
