//
//  JEFileLoggerSettings.h
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

#import "JEBaseLoggerSettings.h"

/*! JEFileLoggerSettings provides configurations to JEDebugging file logging.
 */
@interface JEFileLoggerSettings : JEBaseLoggerSettings

/*! The combination of JELogLevelMask flags that will be output by the file logger. Defaults to (JELogLevelNotice | JELogLevelAlert | JELogLevelFatal)
 */
@property (nonatomic, assign) JELogLevelMask logLevelMask;

/*! The combination of JELogMessageHeaderMask flags for log headers that will be displayed by the file logger. Defaults to JELogMessageHeaderAll
 */
@property (nonatomic, assign) JELogMessageHeaderMask logMessageHeaderMask;

/*! The root directory URL for log files. Defaults to the application Caches/Logs/ directory
 */
@property (nonatomic, copy, nonnull) NSURL *fileLogsDirectoryURL;

/*! The memory threshold before logs are flushed to disk. Defaults to 100KB
 */
@property (nonatomic, assign) unsigned long long numberOfBytesInMemoryBeforeWritingToFile;

/*! The number of days from creation date before a log file is deleted (each log file only contains data for a single day). Defaults to 7 days
 */
@property (nonatomic, assign) NSUInteger numberOfDaysBeforeDeletingFile;

@end
