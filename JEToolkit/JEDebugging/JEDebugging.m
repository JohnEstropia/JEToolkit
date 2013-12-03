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

@property (nonatomic, assign) JEConsoleLogHeaderMask consoleLogHeaderMask;
@property (nonatomic, assign) JEConsoleLogHeaderMask HUDLogHeaderMask;
@property (nonatomic, assign) JEConsoleLogHeaderMask fileLogHeaderMask;

@property (nonatomic, assign) JELogLevelMask consoleLogLevelMask;
@property (nonatomic, assign) JELogLevelMask HUDLogLevelMask;
@property (nonatomic, assign) JELogLevelMask fileLogLevelMask;

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
    
    _consoleLogHeaderMask = (JEConsoleLogHeaderQueue | JEConsoleLogHeaderFile | JEConsoleLogHeaderFunction);
    _HUDLogHeaderMask = (JEConsoleLogHeaderQueue | JEConsoleLogHeaderFile | JEConsoleLogHeaderFunction);
    _fileLogHeaderMask = JEConsoleLogHeaderAll;
    
    _consoleLogLevelMask = JELogLevelAll;
    _HUDLogLevelMask = (JELogLevelNotice | JELogLevelAlert);
    _fileLogLevelMask = (JELogLevelNotice | JELogLevelAlert);
    
    _filePendingBytesFlushThreshold = (1024 * 100);
    _fileDayAgeDeleteThreshold = 7;
    
    NSURL *fileLogDirectoryURL = [[NSURL alloc]
                                  initFileURLWithPath:[[NSString appSupportDirectory] stringByAppendingPathComponent:@"logs"]
                                  isDirectory:YES];
#if DEBUG
    fileLogDirectoryURL = [fileLogDirectoryURL URLByAppendingPathComponent:@"debug" isDirectory:YES];
#endif
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *directoryCreateError;
    if (![fileManager
          createDirectoryAtURL:fileLogDirectoryURL
          withIntermediateDirectories:YES
          attributes:nil
          error:&directoryCreateError])
    {
        [JEDebugging
         logInternalError:directoryCreateError
         withHeader:JE_LOG_HEADER
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
         logInternalError:nil
         withHeader:JE_LOG_HEADER
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
         logInternalError:fileHandleError
         withHeader:JE_LOG_HEADER
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

+ (void)logInternalError:(NSError *)error
              withHeader:(JELogHeader)header
                 message:(NSString *)message
{
    JEConsoleLogHeaderMask __block consoleLogHeaderMask;
    JEConsoleLogHeaderMask __block HUDLogHeaderMask;
    JELogLevelMask __block consoleLogLevelMask;
    JELogLevelMask __block HUDLogLevelMask;
    dispatch_sync([self settingsQueue], ^{
        
        JEDebugging *instance = [self sharedInstance];
        
        consoleLogHeaderMask = instance.consoleLogHeaderMask;
        HUDLogHeaderMask = instance.HUDLogHeaderMask;
        
        consoleLogLevelMask = instance.consoleLogLevelMask;
        HUDLogLevelMask = instance.HUDLogLevelMask;
        
    });
    
    NSDictionary *headerEntries = [self
                                   headerEntriesForLogHeader:header
                                   withMask:(consoleLogHeaderMask | HUDLogHeaderMask)];
    
    if (IsEnumBitSet(consoleLogLevelMask, JELogLevelAlert))
    {
        dispatch_barrier_async([JEDebugging consoleLogQueue], ^{
            
            NSMutableString *consoleLogString = [self
                                                 logHeaderStringWithEntries:headerEntries
                                                 withMask:consoleLogHeaderMask];
            
            NSMutableString *errorDescription = [error detailedDescription];
            [errorDescription indentByLevel:1];
            
            if (errorDescription)
            {
                [consoleLogString appendFormat:
                 @"%@ %@\n  %@ %@\n",
                 [JEDebugging defaultAlertBulletString],
                 message,
                 [JEDebugging defaultDumpBulletString],
                 errorDescription];
            }
            else
            {
                [consoleLogString appendFormat:
                 @"%@ %@\n",
                 [JEDebugging defaultAlertBulletString],
                 message];
            }
            
            puts([consoleLogString UTF8String]);
            
        });
    }
    if (IsEnumBitSet(HUDLogLevelMask, JELogLevelAlert))
    {
        NSMutableString *HUDString = [self
                                      logHeaderStringWithEntries:headerEntries
                                      withMask:HUDLogHeaderMask];
    }
}

+ (NSDictionary *)headerEntriesForLogHeader:(JELogHeader)header
                                   withMask:(JEConsoleLogHeaderMask)mask
{
    NSMutableDictionary * headerEntries = [[NSMutableDictionary alloc] init];
    headerEntries[@(JEConsoleLogHeaderDate)]
    = (IsEnumBitSet(mask, JEConsoleLogHeaderDate)
       ? [NSString stringWithFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]]
       : [NSString string]);
    headerEntries[@(JEConsoleLogHeaderQueue)]
    = (IsEnumBitSet(mask, JEConsoleLogHeaderQueue)
       ? [NSString stringWithFormat:@"[%s] ", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)]
       : [NSString string]);
    headerEntries[@(JEConsoleLogHeaderFile)]
    = ((IsEnumBitSet(mask, JEConsoleLogHeaderFile) && header.fileName != NULL && header.lineNumber > 0)
       ? [NSString stringWithFormat:@"%s:%li ", header.fileName, (long)header.lineNumber]
       : [NSString string]);
    headerEntries[@(JEConsoleLogHeaderFunction)]
    = ((IsEnumBitSet(mask, JEConsoleLogHeaderFunction) && header.functionName != NULL)
       ? [NSString stringWithFormat:@"%s ", header.functionName]
       : [NSString string]);
    
    return headerEntries;
}

+ (NSMutableString *)logHeaderStringWithEntries:(NSDictionary *)headerEntries
                                       withMask:(JEConsoleLogHeaderMask)mask
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    if (IsEnumBitSet(mask, JEConsoleLogHeaderDate))
    {
        [string appendString:headerEntries[@(JEConsoleLogHeaderDate)]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderQueue))
    {
        [string appendString:headerEntries[@(JEConsoleLogHeaderQueue)]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderFile))
    {
        [string appendString:headerEntries[@(JEConsoleLogHeaderFile)]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderFunction))
    {
        [string appendString:headerEntries[@(JEConsoleLogHeaderFunction)]];
    }
    
    if ([string length] > 0)
    {
        [string appendString:@"\n"];
    }
    
    return string;
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
        
        // Do nothing, just give up
        
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
           header:(JELogHeader)header
            label:(NSString *)label
            value:(NSValue *)wrappedValue
{
    @autoreleasepool {
        
        JEConsoleLogHeaderMask __block consoleLogHeaderMask;
        JEConsoleLogHeaderMask __block HUDLogHeaderMask;
        JEConsoleLogHeaderMask __block fileLogHeaderMask;
        JELogLevelMask __block consoleLogLevelMask;
        JELogLevelMask __block HUDLogLevelMask;
        JELogLevelMask __block fileLogLevelMask;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            fileLogHeaderMask = instance.fileLogHeaderMask;
            
            consoleLogLevelMask = instance.consoleLogLevelMask;
            HUDLogLevelMask = instance.HUDLogLevelMask;
            fileLogLevelMask = instance.fileLogLevelMask;
            
        });
        
        if (!IsEnumBitSet(consoleLogLevelMask, level)
            && !IsEnumBitSet(HUDLogLevelMask, level)
            && !IsEnumBitSet(fileLogLevelMask, level))
        {
            return;
        }
        
        // Note that because of a bug(?) with NSGetSizeAndAlignment, structs and unions with bitfields cannot be wrapped in NSValue, in which case wrappedValue will be nil.
        NSMutableString *description = (wrappedValue
                                        ? [wrappedValue detailedDescriptionIncludeClass:NO includeAddress:NO]
                                        : [[NSMutableString alloc] initWithString:@"(?) { ... }"]);
        [description indentByLevel:1];
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLogHeader:header
                                       withMask:(consoleLogHeaderMask | HUDLogHeaderMask | fileLogHeaderMask)];
        
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
        
        if (IsEnumBitSet(consoleLogLevelMask, level))
        {
            dispatch_sync([self consoleLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *consoleString = [self
                                                      logHeaderStringWithEntries:headerEntries
                                                      withMask:consoleLogHeaderMask];
                    [consoleString appendString:bulletString];
                    [consoleString appendString:@" "];
                    [consoleString appendString:label];
                    [consoleString appendString:@"\n  "];
                    [consoleString appendString:[self defaultDumpBulletString]];
                    [consoleString appendString:@" "];
                    [consoleString appendString:description];
                    [consoleString appendString:@"\n"];
                    
                    puts([consoleString UTF8String]);
                
                }
                
            });
        }
        if (IsEnumBitSet(HUDLogLevelMask, level))
        {
            NSMutableString *HUDString = [self
                                          logHeaderStringWithEntries:headerEntries
                                          withMask:HUDLogHeaderMask];
        }
        if (IsEnumBitSet(fileLogLevelMask, level))
        {
            dispatch_barrier_async([self fileLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *fileString = [self
                                                   logHeaderStringWithEntries:headerEntries
                                                   withMask:fileLogHeaderMask];
                    [fileString appendString:bulletString];
                    [fileString appendString:@" "];
                    [fileString appendString:label];
                    [fileString appendString:@"\n  "];
                    [fileString appendString:[self defaultDumpBulletString]];
                    [fileString appendString:@" "];
                    [fileString appendString:description];
                    [fileString appendString:@"\n\n"];
                    
                    [[self sharedInstance] appendStringToFile:fileString];
                    
                }
                
            });
        }
        
    }
}

+ (void)logLevel:(JELogLevelMask)level
          header:(JELogHeader)header
          format:(NSString *)format, ...
{
    @autoreleasepool {
        
        va_list arguments;
        va_start(arguments, format);
        NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        
        JEConsoleLogHeaderMask __block consoleLogHeaderMask;
        JEConsoleLogHeaderMask __block HUDLogHeaderMask;
        JEConsoleLogHeaderMask __block fileLogHeaderMask;
        JELogLevelMask __block consoleLogLevelMask;
        JELogLevelMask __block HUDLogLevelMask;
        JELogLevelMask __block fileLogLevelMask;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            fileLogHeaderMask = instance.fileLogHeaderMask;
            
            consoleLogLevelMask = instance.consoleLogLevelMask;
            HUDLogLevelMask = instance.HUDLogLevelMask;
            fileLogLevelMask = instance.fileLogLevelMask;
            
        });
        
        if (!IsEnumBitSet(consoleLogLevelMask, level)
            && !IsEnumBitSet(HUDLogLevelMask, level)
            && !IsEnumBitSet(fileLogLevelMask, level))
        {
            return;
        }
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLogHeader:header
                                       withMask:(consoleLogHeaderMask | HUDLogHeaderMask | fileLogHeaderMask)];
        
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
        
        if (IsEnumBitSet(consoleLogLevelMask, level))
        {
            dispatch_sync([self consoleLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *consoleString = [self
                                                      logHeaderStringWithEntries:headerEntries
                                                      withMask:consoleLogHeaderMask];
                    [consoleString appendString:bulletString];
                    [consoleString appendString:@" "];
                    [consoleString appendString:formattedString];
                    [consoleString appendString:@"\n"];
                    
                    puts([consoleString UTF8String]);
                    
                }
                
            });
        }
        if (IsEnumBitSet(HUDLogLevelMask, level))
        {
            NSMutableString *HUDString = [self
                                          logHeaderStringWithEntries:headerEntries
                                          withMask:HUDLogHeaderMask];
        }
        if (IsEnumBitSet(fileLogLevelMask, level))
        {
            dispatch_barrier_async([self fileLogQueue], ^{
                
                @autoreleasepool {
                    
                    NSMutableString *fileString = [self
                                                   logHeaderStringWithEntries:headerEntries
                                                   withMask:fileLogHeaderMask];
                    [fileString appendString:bulletString];
                    [fileString appendString:@" "];
                    [fileString appendString:formattedString];
                    [fileString appendString:@"\n\n"];
                    
                    [[self sharedInstance] appendStringToFile:fileString];
                    
                }
                
            });
        }
        
    }
}

#pragma mark HUD settings

+ (void)setIsHUDEnabled:(BOOL)isHUDEnabled
{
    if ([NSThread isMainThread])
    {
#warning TODO: create view
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
#warning TODO: create view
            
        });
    }
}

#pragma mark log header mask settings

+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLogHeaderMask = mask;
        
    });
}

+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLogHeaderMask = mask;
        
    });
}

+ (void)setFileLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].fileLogHeaderMask = mask;
        
    });
}

#pragma mark log destination mask settings

+ (void)setConsoleLogLevelMask:(JELogLevelMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLogLevelMask = mask;
        
    });
}

+ (void)setHUDLogLevelMask:(JELogLevelMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLogLevelMask = mask;
        
    });
}

+ (void)setFileLogLevelMask:(JELogLevelMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].fileLogLevelMask = mask;
        
    });
}


@end
