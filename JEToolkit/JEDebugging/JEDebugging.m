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
#import "JEAssociatedObjects.h"

#import "NSCalendar+JEToolkit.h"
#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"
#import "NSString+JEToolkit.h"
#import "NSURL+JEToolkit.h"


@interface JEFileLoggerSettings (_JEDebugging)

@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, assign) unsigned long long lastSynchronizedOffset;
@property (nonatomic, assign) BOOL isDisabled;

@end

@implementation JEFileLoggerSettings (_JEDebugging)

JESynthesize(strong, NSFileHandle *, fileHandle, setFileHandle);
JESynthesize(copy, NSURL *, fileURL, setFileURL);
JESynthesize(assign, unsigned long long, lastSynchronizedOffset, setLastSynchronizedOffset);
JESynthesize(assign, BOOL, isDisabled, setIsDisabled);
JESynthesize(copy, void(^)(void), testBlock, setTestBlock);

@end


static const void *_JEDebuggingQueueIDKey = &_JEDebuggingQueueIDKey;
static const void *_JEDebuggingSettingsQueueID = &_JEDebuggingSettingsQueueID;
static const void *_JEDebuggingConsoleLogQueueID = &_JEDebuggingConsoleLogQueueID;
static const void *_JEDebuggingFileLogQueueID = &_JEDebuggingFileLogQueueID;

static NSString *const _JEDebuggingFileLogAttributeKey = @"com.JEDebugging.JEToolkit";
static NSString *const _JEDebuggingFileLogAttributeValue = @"1";


@interface JEDebugging ()

@property (nonatomic, copy) JEConsoleLoggerSettings *consoleLoggerSettings;
@property (nonatomic, copy) JEHUDLoggerSettings *HUDLoggerSettings;
@property (nonatomic, copy) JEFileLoggerSettings *fileLoggerSettings;

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
    
    _consoleLoggerSettings = [consoleLoggerSettings copy];
    _HUDLoggerSettings = [HUDLoggerSettings copy];
    _fileLoggerSettings = [fileLoggerSettings copy];
    
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

- (NSFileHandle *)cachedFileHandleWithThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSFileHandle *fileHandle = fileLoggerSettings.fileHandle;
    if (fileHandle)
    {
        return fileHandle;
    }
    
    if (fileLoggerSettings.isDisabled)
    {
        // We don't want to keep making IO's if we already failed creating the file handle once.
        return nil;
    }
    
    void (^failure)(JELogLocation location, NSString *message, NSError *error)
    = ^(JELogLocation location, NSString *message, NSError *error){
        
        [JEDebugging
         logFileError:error
         location:location
         message:message];
        
        // Prevent retrying
        fileLoggerSettings.isDisabled = YES;
        
    };
    
    NSURL *fileURL = fileLoggerSettings.fileURL;
    if (!fileURL)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *fileLogsDirectoryURL = fileLoggerSettings.fileLogsDirectoryURL;
        NSError *directoryCreateError;
        if (![fileManager
              createDirectoryAtURL:fileLogsDirectoryURL
              withIntermediateDirectories:YES
              attributes:nil
              error:&directoryCreateError])
        {
            failure(JELogLocationCurrent(),
                    @"Failed to create logs directory because of error:",
                    directoryCreateError);
            return nil;
        }
        
        fileURL = [fileLogsDirectoryURL
                   URLByAppendingPathComponent:
                   [[NSString alloc] initWithFormat:@"%@ %@.log",
                    ([NSString applicationBundleVersion] ?: [NSString string]),
                    [[JEDebugging fileNameDateFormatter] stringFromDate:[[NSDate alloc] init]]]
                   isDirectory:NO];
        
        NSString *filePath = [fileURL path];
        if (![fileManager fileExistsAtPath:filePath])
        {
            if (![fileManager createFileAtPath:filePath contents:nil attributes:nil])
            {
                failure(JELogLocationCurrent(),
                        @"Failed to create log file.",
                        nil);
                return nil;
            }
        }
        
        NSError *attributeError;
        if (![fileURL
              setExtendedAttribute:_JEDebuggingFileLogAttributeValue
              forKey:_JEDebuggingFileLogAttributeKey
              error:&attributeError])
        {
            failure(JELogLocationCurrent(),
                    @"Failed to attach extended attribute to log file because of error:",
                    attributeError);
            return nil;
        }
        
        fileLoggerSettings.fileURL = fileURL;
    }
    
    NSString *attributeString;
    NSError *attributeError;
    if (![fileURL
          getExtendedAttribute:&attributeString
          forKey:_JEDebuggingFileLogAttributeKey
          error:&attributeError])
    {
        failure(JELogLocationCurrent(),
                @"Failed to read extended attribute from log file because of error:",
                attributeError);
        return nil;
    }
    
    if (![_JEDebuggingFileLogAttributeValue isEqualToString:attributeString])
    {
        failure(JELogLocationCurrent(),
                @"Extended attribute read from log file is incorrect.",
                nil);
        return nil;
    }
    
    NSError *fileHandleError;
    fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&fileHandleError];
    if (!fileHandle)
    {
        failure(JELogLocationCurrent(),
                @"Failed to open log file handle because of error:",
                fileHandleError);
        return nil;
    }
    
    [fileHandle seekToEndOfFile];
    
    fileLoggerSettings.fileHandle = fileHandle;
    
    [self deleteOldFileLogsWithThreadSafeSettings:fileLoggerSettings];
    
    return fileHandle;
}

- (void)deleteOldFileLogsWithThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSURL *currentFileURL = fileLoggerSettings.fileURL;
    if (!currentFileURL)
    {
        return;
    }
    
    NSDateComponents *dayAgo = [[NSDateComponents alloc] init];
    [dayAgo setDay:-fileLoggerSettings.numberOfDaysBeforeDeletingFile];
    
    NSDate *earliestAllowedDate = [[NSCalendar gregorianCalendar]
                                   dateByAddingComponents:dayAgo
                                   toDate:[[NSDate alloc] init]
                                   options:kNilOptions];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileEnumerationError;
    NSArray *fileURLs = [fileManager
                         contentsOfDirectoryAtURL:fileLoggerSettings.fileLogsDirectoryURL
                         includingPropertiesForKeys:@[(__bridge NSString *)kCFURLIsRegularFileKey,
                                                      (__bridge NSString *)kCFURLCreationDateKey]
                         options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                  | NSDirectoryEnumerationSkipsPackageDescendants
                                  | NSDirectoryEnumerationSkipsHiddenFiles)
                         error:&fileEnumerationError];
    if (!fileURLs)
    {
        return;
    }
    
    for (NSURL *fileURL in fileURLs)
    {
        if ([fileURL isEqual:currentFileURL])
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
        
        NSString *extendedAttribute;
        [fileURL
         getExtendedAttribute:&extendedAttribute
         forKey:_JEDebuggingFileLogAttributeKey
         error:NULL];
        if (![_JEDebuggingFileLogAttributeValue isEqualToString:extendedAttribute])
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
    withThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    @try {
        
        [[self cachedFileHandleWithThreadSafeSettings:fileLoggerSettings]
         writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [self flushFileHandleIfNeededOrForced:NO withThreadSafeSettings:fileLoggerSettings];
        
    }
    @catch (NSException *exception) {
        
        [JEDebugging
         logFileError:exception
         location:JELogLocationCurrent()
         message:@"Failed appending to log file because of exception:"];
        
    }
}

- (void)flushFileHandleIfNeededOrForced:(BOOL)forceSave
                 withThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings
{
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSFileHandle *fileHandle = fileLoggerSettings.fileHandle;
    if (!fileHandle)
    {
        return;
    }
    
    unsigned long long offsetInFile = [fileHandle offsetInFile];
    unsigned long long lastSynchronizedOffset = fileLoggerSettings.lastSynchronizedOffset;
    
    if (offsetInFile == lastSynchronizedOffset)
    {
        return;
    }
    
    if (forceSave
        || (offsetInFile - lastSynchronizedOffset) >= fileLoggerSettings.numberOfBytesInMemoryBeforeWritingToFile)
    {
        [fileHandle synchronizeFile];
        fileLoggerSettings.lastSynchronizedOffset = offsetInFile;
    }
}


#pragma mark @selector

- (void)applicationWillResignActive:(NSNotification *)note
{
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_async([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
    
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
    });
}

- (void)applicationWillTerminate:(NSNotification *)note
{
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
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
                    [logString appendFormat:@"%@ %@\n  %@ %@\n\n",
                     bulletString, label, [self defaultDumpBulletString], description];
                    
                    [[self sharedInstance]
                     appendStringToFile:logString
                     withThreadSafeSettings:fileLoggerSettings];
                    
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
                    [logString appendFormat:@"%@ %@\n",
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
            [logString appendFormat:@"%@ %@\n", bulletString, formattedString];
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
                    
                    [[self sharedInstance]
                     appendStringToFile:logString
                     withThreadSafeSettings:fileLoggerSettings];
                    
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
