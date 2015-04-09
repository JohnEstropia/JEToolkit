//
//  JEFileLoggerSettings.m
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

#import "JEFileLoggerSettings.h"

#import "NSString+JEToolkit.h"


@implementation JEFileLoggerSettings

#pragma mark - NSObject

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    self.logLevelMask = (JELogLevelNotice | JELogLevelAlert | JELogLevelFatal);
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


#pragma mark - JEBaseLoggerSettings

@dynamic logLevelMask;
@dynamic logMessageHeaderMask;


@end
