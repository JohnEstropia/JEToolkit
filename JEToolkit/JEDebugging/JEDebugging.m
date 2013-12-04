//
//  JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDebugging.h"

#import <objc/runtime.h>

#import "JESafetyHelpers.h"
#import "NSString+JEToolkit.h"
#import "NSCalendar+JEToolkit.h"
#import "NSObject+JEDebugging.h"
#import "NSMutableString+JEDebugging.h"


static const void *_JEDebuggingQueueIDKey = &_JEDebuggingQueueIDKey;
static const void *_JEDebuggingSettingsQueueID = &_JEDebuggingSettingsQueueID;
static const void *_JEDebuggingConsoleLogQueueID = &_JEDebuggingConsoleLogQueueID;
static const void *_JEDebuggingFileLogQueueID = &_JEDebuggingFileLogQueueID;


@interface JEDebugging ()

@property (nonatomic, copy) JEConsoleLoggerSettings *consoleLoggerSettings;
@property (nonatomic, copy) JEHUDLoggerSettings *HUDLoggerSettings;
@property (nonatomic, copy) JEFileLoggerSettings *fileLoggerSettings;

#warning TODO: setter methods
@property (nonatomic, assign) unsigned long long filePendingBytesFlushThreshold;
@property (nonatomic, assign) NSUInteger fileDayAgeDeleteThreshold;

@property (nonatomic, copy, readonly) NSURL *fileLogDirectoryURL;
@property (nonatomic, copy) NSURL *fileLogFileURL;
@property (nonatomic, strong) NSFileHandle *fileLogFileHandle;
@property (nonatomic, assign) unsigned long long lastSynchronizedOffset;

@end


@implementation JEDebugging

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    JEConsoleLoggerSettings *consoleLoggerSettings = [[JEConsoleLoggerSettings alloc] init];
    JEHUDLoggerSettings *HUDLoggerSettings = [[JEHUDLoggerSettings alloc] init];
    JEFileLoggerSettings *fileLoggerSettings = [[JEFileLoggerSettings alloc] init];
    
    _consoleLoggerSettings = consoleLoggerSettings;
    _HUDLoggerSettings = HUDLoggerSettings;
    _fileLoggerSettings = fileLoggerSettings;
    
    _filePendingBytesFlushThreshold = (1024 * 100);
    _fileDayAgeDeleteThreshold = 7;
    
#warning TODO: create file and open handle only when needed
    NSURL *fileLogDirectoryURL = [[NSURL alloc]
                                  initFileURLWithPath:[[NSString cachesDirectory] stringByAppendingPathComponent:@"Logs"]
                                  isDirectory:YES];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *directoryCreateError;
    if (![fileManager
          createDirectoryAtURL:fileLogDirectoryURL
          withIntermediateDirectories:YES
          attributes:nil
          error:&directoryCreateError])
    {
        [JEDebugging
         logFileError:directoryCreateError
         location:JELogLocationCurrent()
         message:@"Failed to create logs directory because of error:"];
        return self;
    }
    
    NSURL *fileLogFileURL = [fileLogDirectoryURL
                             URLByAppendingPathComponent:
                             [[NSString alloc] initWithFormat:@"%@ %@.log",
                              [NSString applicationBundleVersion],
                              [[JEDebugging fileNameDateFormatter] stringFromDate:[[NSDate alloc] init]]]
                             isDirectory:YES];
    
    NSString *fileLogFilePath = [fileLogFileURL path];
    if (![fileManager fileExistsAtPath:fileLogFilePath]
        && ![fileManager createFileAtPath:fileLogFilePath contents:nil attributes:nil])
    {
        [JEDebugging
         logFileError:nil
         location:JELogLocationCurrent()
         message:@"Failed to create log file."];
        return self;
    }
    
    NSError *fileHandleError;
    NSFileHandle *fileLogFileHandle = [NSFileHandle
                                       fileHandleForWritingToURL:fileLogFileURL
                                       error:&fileHandleError];
    if (!fileLogFileHandle)
    {
        [JEDebugging
         logFileError:fileHandleError
         location:JELogLocationCurrent()
         message:@"Failed to open log file because of error:"];
        return self;
    }
    
    [fileLogFileHandle seekToEndOfFile];
    
    _fileLogDirectoryURL = fileLogDirectoryURL;
    _fileLogFileURL = fileLogFileURL;
    _fileLogFileHandle = fileLogFileHandle;
    
    dispatch_barrier_async([JEDebugging fileLogQueue], ^{
        
        [self deleteOldFileLogs];
        
    });
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    [center
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    [center
     addObserver:self
     selector:@selector(applicationWillTerminate:)
     name:UIApplicationWillTerminateNotification
     object:nil];
    
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     removeObserver:self
     name:UIApplicationWillResignActiveNotification
     object:nil];
    [center
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    [center
     removeObserver:self
     name:UIApplicationWillTerminateNotification
     object:nil];
}


#pragma mark - Private

#pragma mark shared objects

+ (JEDebugging *)sharedInstance
{
    static JEDebugging *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[JEDebugging alloc] init];
        
    });
    return sharedInstance;
}

+ (NSDictionary *)characterEscapeMapping
{
    static NSDictionary *escapeMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // http://en.wikipedia.org/wiki/ASCII
        escapeMapping = @{ @"\0" : @"\\0",
                           @"\a" : @"\\a",
                           @"\b" : @"\\b",
                           @"\t" : @"\\t",
                           @"\n" : @"\\n",
                           @"\v" : @"\\v",
                           @"\f" : @"\\f",
                           @"\r" : @"\\r",
                           @"\e" : @"\\e",
                           @"\"" : @"\\\"" };
        
    });
    return escapeMapping;
}

+ (NSDateFormatter *)consoleDateFormatter
{
    static NSDateFormatter *consoleDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setCalendar:[NSCalendar gregorianCalendar]];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'SSS"];
        consoleDateFormatter = formatter;
        
    });
    return consoleDateFormatter;
}

+ (NSDateFormatter *)fileNameDateFormatter
{
    static NSDateFormatter *consoleDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setCalendar:[NSCalendar gregorianCalendar]];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd"];
        consoleDateFormatter = formatter;
        
    });
    return consoleDateFormatter;
}

+ (dispatch_queue_t)settingsQueue
{
    static dispatch_queue_t settingsQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        settingsQueue = dispatch_queue_create("JEDebugging.settingsQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(settingsQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingSettingsQueueID,
                                    NULL);
        
    });
    return settingsQueue;
}

+ (dispatch_queue_t)consoleLogQueue
{
    static dispatch_queue_t consoleLogQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        consoleLogQueue = dispatch_queue_create("JEDebugging.consoleLogQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(consoleLogQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingConsoleLogQueueID,
                                    NULL);
        
    });
    return consoleLogQueue;
}

+ (dispatch_queue_t)fileLogQueue
{
    static dispatch_queue_t fileLogQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        fileLogQueue = dispatch_queue_create("JEDebugging.fileLogQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(fileLogQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingFileLogQueueID,
                                    NULL);
        
    });
    return fileLogQueue;
}

#pragma mark default bullets

+ (NSString *)defaultTraceBulletString
{
    return @"🔹";
}

+ (NSString *)defaultLogBulletString
{
    return @"🔸";
}

+ (NSString *)defaultDumpBulletString
{
    return @"↪︎";
}

+ (NSString *)defaultAlertBulletString
{
    return @"⚠️";
}

#pragma mark utilities

+ (void)logFileError:(id)errorOrException
            location:(JELogLocation)location
             message:(NSString *)message
{
    JEConsoleLoggerSettings __block *consoleLoggerSettings;
    JEHUDLoggerSettings __block *HUDLoggerSettings;
    dispatch_sync([self settingsQueue], ^{
        
        JEDebugging *instance = [self sharedInstance];
        consoleLoggerSettings = instance.consoleLoggerSettings;
        HUDLoggerSettings = instance.HUDLoggerSettings;
        
    });
    
    NSDictionary *headerEntries = [self
                                   headerEntriesForLocation:location
                                   withMask:(consoleLoggerSettings.logMessageHeaderMask
                                             | HUDLoggerSettings.logMessageHeaderMask)];
    
    if (IsEnumBitSet(consoleLoggerSettings.logLevelMask, JELogLevelAlert))
    {
        dispatch_barrier_async([JEDebugging consoleLogQueue], ^{
            
            NSMutableString *logString = [self messageHeaderFromEntries:headerEntries
                                                           withSettings:consoleLoggerSettings];
            
            NSMutableString *errorDescription = [errorOrException detailedDescription];
            if (errorDescription)
            {
                [errorDescription indentByLevel:1];
            
                [logString appendFormat:
                 @"%@ %@\n  %@ %@\n",
                 [JEDebugging defaultAlertBulletString],
                 message,
                 [JEDebugging defaultDumpBulletString],
                 errorDescription];
            }
            else
            {
                [logString appendFormat:
                 @"%@ %@\n",
                 [JEDebugging defaultAlertBulletString],
                 message];
            }
            
            puts([logString UTF8String]);
            
        });
    }
    if (IsEnumBitSet(HUDLoggerSettings.logLevelMask, JELogLevelAlert))
    {
        NSMutableString *logString = [self
                                      messageHeaderFromEntries:headerEntries
                                      withSettings:HUDLoggerSettings];
    }
}

+ (NSDictionary *)headerEntriesForLocation:(JELogLocation)location
                                  withMask:(JELogMessageHeaderMask)logMessageHeaderMask
{
    NSMutableDictionary * headerEntries = [[NSMutableDictionary alloc] init];
    
    headerEntries[@(JELogMessageHeaderDate)]
    = (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderDate)
       ? [NSString stringWithFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderQueue)]
    = (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderQueue)
       ? [NSString stringWithFormat:@"[%s] ", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderSourceFile)]
    = ((IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderSourceFile)
        && location.fileName != NULL
        && location.lineNumber > 0)
       ? [NSString stringWithFormat:@"%s:%li ", location.fileName, (long)location.lineNumber]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderFunction)]
    = ((IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderFunction) && location.functionName != NULL)
       ? [NSString stringWithFormat:@"%s ", location.functionName]
       : [NSString string]);
    
    return headerEntries;
}

+ (NSMutableString *)messageHeaderFromEntries:(NSDictionary *)logMessageHeaderEntries
                                 withSettings:(JEBaseLoggerSettings *)loggerSettings
{
    JELogMessageHeaderMask logMessageHeaderMask = loggerSettings.logMessageHeaderMask;
    NSMutableString *messageHeader = [[NSMutableString alloc] init];
    
    if (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderDate))
    {
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderDate)]];
    }
    if (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderQueue))
    {
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderQueue)]];
    }
    if (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderSourceFile))
    {
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderSourceFile)]];
    }
    if (IsEnumBitSet(logMessageHeaderMask, JELogMessageHeaderFunction))
    {
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderFunction)]];
    }
    
    if ([messageHeader length] > 0)
    {
        [messageHeader appendString:@"\n"];
    }
    
    return messageHeader;
}

- (void)deleteOldFileLogs
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSDateComponents *dayAgo = [[NSDateComponents alloc] init];
    [dayAgo setDay:(-self.fileDayAgeDeleteThreshold)];
    
    NSDate *earliestAllowedDate = [[NSCalendar gregorianCalendar]
                                   dateByAddingComponents:dayAgo
                                   toDate:[[NSDate alloc] init]
                                   options:kNilOptions];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileEnumerationError;
    for (NSURL *fileURL in [fileManager
                            contentsOfDirectoryAtURL:self.fileLogDirectoryURL
                            includingPropertiesForKeys:@[(__bridge NSString *)kCFURLIsRegularFileKey,
                                                         (__bridge NSString *)kCFURLCreationDateKey]
                            options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                     | NSDirectoryEnumerationSkipsPackageDescendants
                                     | NSDirectoryEnumerationSkipsHiddenFiles)
                            error:&fileEnumerationError])
    {
        if ([fileURL isEqual:self.fileLogFileURL])
        {
            continue;
        }
        
        NSNumber *isRegularFile;
        [fileURL
         getResourceValue:&isRegularFile
         forKey:(__bridge NSString *)kCFURLIsRegularFileKey
         error:NULL];
        
        if (![isRegularFile boolValue])
        {
            continue;
        }
        
        NSDate *creationDate;
        [fileURL
         getResourceValue:&creationDate
         forKey:(__bridge NSString *)kCFURLCreationDateKey
         error:NULL];
        
        if ([creationDate compare:earliestAllowedDate] != NSOrderedAscending)
        {
            continue;
        }
        
        [fileManager removeItemAtURL:fileURL error:NULL];
    }
}

- (void)appendStringToFile:(NSString *)string
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    @try {
        
        [self.fileLogFileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [self flushFileHandleIfNeededOrForced:NO];
        
    }
    @catch (NSException *exception) {
        
        [JEDebugging
         logFileError:exception
         location:JELogLocationCurrent()
         message:@"Failed appending to log file because of exception:"];
        
    }
}

- (void)flushFileHandleIfNeededOrForced:(BOOL)forceSave
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSFileHandle *fileLogFileHandle = self.fileLogFileHandle;
    unsigned long long offsetInFile = [fileLogFileHandle offsetInFile];
    unsigned long long lastSynchronizedOffset = self.lastSynchronizedOffset;
    
    if (offsetInFile == lastSynchronizedOffset)
    {
        return;
    }
    
    if (forceSave
        || (offsetInFile - lastSynchronizedOffset) >= self.filePendingBytesFlushThreshold)
    {
        [fileLogFileHandle synchronizeFile];
        self.lastSynchronizedOffset = offsetInFile;
    }
}


#pragma mark @selector

- (void)applicationWillResignActive:(NSNotification *)note
{
    dispatch_barrier_async([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES];
        
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
    
        [self flushFileHandleIfNeededOrForced:YES];
        
    });
}

- (void)applicationWillTerminate:(NSNotification *)note
{
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES];
        
    });
}


#pragma mark - Public

#pragma mark logging

+ (void)dumpLevel:(JELogLevelMask)level
         location:(JELogLocation)location
            label:(NSString *)label
            value:(NSValue *)wrappedValue
{
    @autoreleasepool {
        
        JEConsoleLoggerSettings __block *consoleLoggerSettings;
        JEHUDLoggerSettings __block *HUDLoggerSettings;
        JEFileLoggerSettings __block *fileLoggerSettings;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLoggerSettings = instance.consoleLoggerSettings;
            HUDLoggerSettings = instance.HUDLoggerSettings;
            fileLoggerSettings = instance.fileLoggerSettings;
            
        });
        
        if (!IsEnumBitSet(consoleLoggerSettings.logLevelMask, level)
            && !IsEnumBitSet(HUDLoggerSettings.logLevelMask, level)
            && !IsEnumBitSet(fileLoggerSettings.logLevelMask, level))
        {
            return;
        }
        
        // Note that because of a bug(?) with NSGetSizeAndAlignment, structs and unions with bitfields cannot be wrapped in NSValue, in which case wrappedValue will be nil.
        NSMutableString *description = (wrappedValue
                                        ? [wrappedValue detailedDescriptionIncludeClass:NO includeAddress:NO]
                                        : [[NSMutableString alloc] initWithString:@"(?) { ... }"]);
        [description indentByLevel:1];
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLocation:location
                                       withMask:(consoleLoggerSettings.logMessageHeaderMask
                                                 | HUDLoggerSettings.logMessageHeaderMask
                                                 | fileLoggerSettings.logMessageHeaderMask)];
        NSString *bulletString;
        if (IsEnumBitSet(level, JELogLevelAlert))
        {
            bulletString = [self defaultAlertBulletString];
        }
        else if (IsEnumBitSet(level, JELogLevelNotice))
        {
            bulletString = [self defaultLogBulletString];
        }
        else
        {
            bulletString = [self defaultTraceBulletString];
        }
        
        if (IsEnumBitSet(consoleLoggerSettings.logLevelMask, level))
        {
            dispatch_sync([self consoleLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:consoleLoggerSettings];
                    [logString appendFormat:@"%@ %@\n  %@ %@\n",
                     bulletString, label, [self defaultDumpBulletString], description];
                    
                    puts([logString UTF8String]);
                
                }
                
            });
        }
        if (IsEnumBitSet(HUDLoggerSettings.logLevelMask, level))
        {
            NSMutableString *logString = [self
                                          messageHeaderFromEntries:headerEntries
                                          withSettings:fileLoggerSettings];
            [logString appendFormat:@"%@ %@\n  %@ %@\n",
             bulletString, label, [self defaultDumpBulletString], description];
        }
        if (IsEnumBitSet(fileLoggerSettings.logLevelMask, level))
        {
            dispatch_barrier_async([self fileLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:fileLoggerSettings];
                    [logString appendFormat:@"%@ %@\n  %@ %@\n",
                     bulletString, label, [self defaultDumpBulletString], description];
                    
                    [[self sharedInstance] appendStringToFile:logString];
                    
                }
                
            });
        }
        
    }
}

+ (void)logLevel:(JELogLevelMask)level
        location:(JELogLocation)location
          format:(NSString *)format, ...
{
    @autoreleasepool {
        
        va_list arguments;
        va_start(arguments, format);
        NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        
        JEConsoleLoggerSettings __block *consoleLoggerSettings;
        JEHUDLoggerSettings __block *HUDLoggerSettings;
        JEFileLoggerSettings __block *fileLoggerSettings;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLoggerSettings = instance.consoleLoggerSettings;
            HUDLoggerSettings = instance.HUDLoggerSettings;
            fileLoggerSettings = instance.fileLoggerSettings;
            
        });
        
        if (!IsEnumBitSet(consoleLoggerSettings.logLevelMask, level)
            && !IsEnumBitSet(HUDLoggerSettings.logLevelMask, level)
            && !IsEnumBitSet(fileLoggerSettings.logLevelMask, level))
        {
            return;
        }
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLocation:location
                                       withMask:(consoleLoggerSettings.logMessageHeaderMask
                                                 | HUDLoggerSettings.logMessageHeaderMask
                                                 | fileLoggerSettings.logMessageHeaderMask)];
        NSString *bulletString;
        if (IsEnumBitSet(level, JELogLevelAlert))
        {
            bulletString = [self defaultAlertBulletString];
        }
        else if (IsEnumBitSet(level, JELogLevelNotice))
        {
            bulletString = [self defaultLogBulletString];
        }
        else
        {
            bulletString = [self defaultTraceBulletString];
        }
        
        if (IsEnumBitSet(consoleLoggerSettings.logLevelMask, level))
        {
            dispatch_sync([self consoleLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:consoleLoggerSettings];
                    [logString appendFormat:@"%@ %@\n\n",
                     bulletString, formattedString];
                    
                    puts([logString UTF8String]);
                    
                }
                
            });
        }
        if (IsEnumBitSet(HUDLoggerSettings.logLevelMask, level))
        {
            NSMutableString *logString = [self
                                          messageHeaderFromEntries:headerEntries
                                          withSettings:HUDLoggerSettings];
            [logString appendFormat:@"%@ %@\n\n", bulletString, formattedString];
        }
        if (IsEnumBitSet(fileLoggerSettings.logLevelMask, level))
        {
            dispatch_barrier_async([self fileLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:fileLoggerSettings];
                    [logString appendFormat:@"%@ %@\n\n",
                     bulletString, formattedString];
                    
                    [[self sharedInstance] appendStringToFile:logString];
                    
                }
                
            });
        }
        
    }
}

#pragma mark logger settings

+ (JEConsoleLoggerSettings *)copyConsoleLoggerSettings
{
    JEConsoleLoggerSettings *__block settings;
    dispatch_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].consoleLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setConsoleLoggerSettings:(JEConsoleLoggerSettings *)consoleLoggerSettings
{
    NSCParameterAssert(consoleLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLoggerSettings = [consoleLoggerSettings copy];
        
    });
}

+ (JEHUDLoggerSettings *)copyHUDLoggerSettings
{
    JEHUDLoggerSettings *__block settings;
    dispatch_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].HUDLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setHUDLoggerSettings:(JEHUDLoggerSettings *)HUDLoggerSettings
{
    NSCParameterAssert(HUDLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLoggerSettings = [HUDLoggerSettings copy];
        
    });
}

+ (JEFileLoggerSettings *)copyFileLoggerSettings
{
    JEFileLoggerSettings *__block settings;
    dispatch_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].fileLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setFileLoggerSettings:(JEFileLoggerSettings *)fileLoggerSettings
{
    NSCParameterAssert(fileLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].fileLoggerSettings = [fileLoggerSettings copy];
        
    });
}


@end
