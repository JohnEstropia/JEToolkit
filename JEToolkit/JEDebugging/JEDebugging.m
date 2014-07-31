//
//  JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDebugging.h"

#import <objc/runtime.h>

#ifdef DEBUG
#include <sys/sysctl.h>
#endif

#import "JESafetyHelpers.h"

#import "NSCalendar+JEToolkit.h"
#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEToolkit.h"
#import "NSString+JEToolkit.h"
#import "NSURL+JEToolkit.h"

#import "JEHUDLogView.h"


#define JEDebuggingReverseDNSPrefix   "com.JEToolkit.JEDebugging."


static const void *_JEDebuggingQueueIDKey = &_JEDebuggingQueueIDKey;
static const void *_JEDebuggingSettingsQueueID = &_JEDebuggingSettingsQueueID;
static const void *_JEDebuggingConsoleLogQueueID = &_JEDebuggingConsoleLogQueueID;
static const void *_JEDebuggingFileLogQueueID = &_JEDebuggingFileLogQueueID;

static NSString *const _JEDebuggingFileLogAttributeKey = @"" JEDebuggingReverseDNSPrefix "logFileAttribute";
static NSString *const _JEDebuggingFileLogAttributeValue = @"1";


@interface JEDebugging ()

@property (nonatomic, assign) BOOL isStarted;

@property (nonatomic, strong) JEConsoleLoggerSettings *consoleLoggerSettings;
@property (nonatomic, strong) JEHUDLoggerSettings *HUDLoggerSettings;
@property (nonatomic, strong) JEFileLoggerSettings *fileLoggerSettings;

// File log attributes
@property (nonatomic, strong) NSFileHandle *fileLogHandle;
@property (nonatomic, copy) NSURL *fileLogURL;
@property (nonatomic, assign) unsigned long long fileLogLastSynchronizedOffset;
@property (nonatomic, assign) BOOL fileLogIsDisabled;

// HUD log attributes
@property (nonatomic, strong) JEHUDLogView *HUDLogView;

@end


@implementation JEDebugging

#pragma mark - NSObject

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    _consoleLoggerSettings = [[JEConsoleLoggerSettings alloc] init];
    _HUDLoggerSettings = [[JEHUDLoggerSettings alloc] init];
    _fileLoggerSettings = [[JEFileLoggerSettings alloc] init];
    
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
    [center
     addObserver:self
     selector:@selector(windowDidBecomeKeyWindow:)
     name:UIWindowDidBecomeKeyNotification
     object:nil];
    
    return self;
}

- (void)dealloc {
    
    [[UIApplication sharedApplication]
     removeObserver:self
     forKeyPath:JEKeypath(UIApplication *, keyWindow)
     context:NULL];
    
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
    [center
     removeObserver:self
     name:UIWindowDidBecomeKeyNotification
     object:nil];
}


#pragma mark - Private

#pragma mark shared objects

+ (JEDebugging *)sharedInstance {
    
    static JEDebugging *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[JEDebugging alloc] init];
        
    });
    return sharedInstance;
}

+ (NSDictionary *)characterEscapeMapping {
    
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

+ (NSDateFormatter *)consoleDateFormatter {
    
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

+ (NSDateFormatter *)fileNameDateFormatter {
    
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

+ (dispatch_queue_t)settingsQueue {
    
    static dispatch_queue_t settingsQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        settingsQueue = dispatch_queue_create(JEDebuggingReverseDNSPrefix "settingsQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(settingsQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingSettingsQueueID,
                                    NULL);
        
    });
    return settingsQueue;
}

+ (dispatch_queue_t)consoleLogQueue {
    
    static dispatch_queue_t consoleLogQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        consoleLogQueue = dispatch_queue_create(JEDebuggingReverseDNSPrefix "consoleLogQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(consoleLogQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingConsoleLogQueueID,
                                    NULL);
        
    });
    return consoleLogQueue;
}

+ (dispatch_queue_t)fileLogQueue {
    
    static dispatch_queue_t fileLogQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        fileLogQueue = dispatch_queue_create(JEDebuggingReverseDNSPrefix "fileLogQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(fileLogQueue,
                                    _JEDebuggingQueueIDKey,
                                    (void *)_JEDebuggingFileLogQueueID,
                                    NULL);
        
    });
    return fileLogQueue;
}

#pragma mark default bullets

+ (NSString *)defaultTraceBulletString {
    
    return @"🔹";
}

+ (NSString *)defaultLogBulletString {
    
    return @"🔸";
}

+ (NSString *)defaultDumpBulletString {
    
    return @"↪︎";
}

+ (NSString *)defaultAlertBulletString {
    
    return @"⚠️";
}

+ (NSString *)defaultAssertBulletString {
    
    return @"❗";
}

#pragma mark utilities

+ (void)logFileError:(id)errorOrException
            location:(JELogLocation)location
             message:(NSString *)message {
    
    if (![self sharedInstance].isStarted) {
        
        return;
    }
    
    JEConsoleLoggerSettings *__block consoleLoggerSettings;
    JEHUDLoggerSettings *__block HUDLoggerSettings;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        JEDebugging *instance = [self sharedInstance];
        consoleLoggerSettings = instance.consoleLoggerSettings;
        HUDLoggerSettings = instance.HUDLoggerSettings;
        
    });
    
    NSDictionary *headerEntries = [self
                                   headerEntriesForLocation:location
                                   withMask:(consoleLoggerSettings.logMessageHeaderMask
                                             | HUDLoggerSettings.logMessageHeaderMask)];
    
    NSMutableString *errorDescription = [NSMutableString stringWithString:
                                         [errorOrException
                                          loggingDescriptionIncludeClass:YES
                                          includeAddress:YES]];
    if (errorDescription) {
        
        [errorDescription indentByLevel:1];
    }
    
    if (JEEnumBitmasked(consoleLoggerSettings.logLevelMask, JELogLevelAlert)) {
        
        dispatch_barrier_async([JEDebugging consoleLogQueue], ^{
            
            @autoreleasepool {
                
                NSMutableString *logString = [self messageHeaderFromEntries:headerEntries
                                                               withSettings:consoleLoggerSettings];
                if (errorDescription) {
                    
                    [logString appendFormat:
                     @"%@ %@\n  %@ %@\n",
                     [JEDebugging defaultAlertBulletString],
                     message,
                     [JEDebugging defaultDumpBulletString],
                     errorDescription];
                }
                else {
                    
                    [logString appendFormat:
                     @"%@ %@\n",
                     [JEDebugging defaultAlertBulletString],
                     message];
                }
                
                puts([logString UTF8String]);
                
            }
            
        });
    }
    if (JEEnumBitmasked(HUDLoggerSettings.logLevelMask, JELogLevelAlert)) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @autoreleasepool {
                
                NSMutableString *logString = [self
                                              messageHeaderFromEntries:headerEntries
                                              withSettings:HUDLoggerSettings];
                if (errorDescription) {
                    
                    [logString appendFormat:
                     @"%@ %@\n  %@ %@",
                     [JEDebugging defaultAlertBulletString],
                     message,
                     [JEDebugging defaultDumpBulletString],
                     errorDescription];
                }
                else {
                    
                    [logString appendFormat:
                     @"%@ %@",
                     [JEDebugging defaultAlertBulletString],
                     message];
                }
                
                [[self sharedInstance]
                 appendStringToHUD:logString
                 withThreadSafeSettings:HUDLoggerSettings];
                
            }
            
        });
    }
}

+ (NSDictionary *)headerEntriesForLocation:(JELogLocation)location
                                  withMask:(JELogMessageHeaderMask)logMessageHeaderMask {
    
    static const char *(^getQueueLabel)(void);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        if ([systemVersion compareWithVersion:@"7.0"] != NSOrderedAscending) {
            
            getQueueLabel = ^const char *{
                
                return dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            };
        }
        else if ([systemVersion compareWithVersion:@"6.1"] != NSOrderedAscending) {
            
            getQueueLabel = ^const char *{
                
                JE_PRAGMA_PUSH
                JE_PRAGMA_IGNORE("-Wdeprecated-declarations")
                return dispatch_queue_get_label(dispatch_get_current_queue());
                JE_PRAGMA_POP
            };
        }
        else {
            
            getQueueLabel = ^const char *{
                
                return "";
            };
        }
    });
    
    NSMutableDictionary * headerEntries = [[NSMutableDictionary alloc] init];
    
    headerEntries[@(JELogMessageHeaderDate)]
    = (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderDate)
       ? [NSString stringWithFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderQueue)]
    = (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderQueue)
       ? [NSString stringWithFormat:@"[%s] ", getQueueLabel()]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderSourceFile)]
    = ((JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderSourceFile)
        && location.fileName != NULL
        && location.lineNumber > 0)
       ? [NSString stringWithFormat:@"%s:%li ", location.fileName, (long)location.lineNumber]
       : [NSString string]);
    headerEntries[@(JELogMessageHeaderFunction)]
    = ((JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderFunction) && location.functionName != NULL)
       ? [NSString stringWithFormat:@"%s ", location.functionName]
       : [NSString string]);
    
    return headerEntries;
}

+ (NSMutableString *)messageHeaderFromEntries:(NSDictionary *)logMessageHeaderEntries
                                 withSettings:(JEBaseLoggerSettings *)loggerSettings {
    
    JELogMessageHeaderMask logMessageHeaderMask = loggerSettings.logMessageHeaderMask;
    NSMutableString *messageHeader = [[NSMutableString alloc] init];
    
    if (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderDate)) {
        
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderDate)]];
    }
    if (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderQueue)) {
        
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderQueue)]];
    }
    if (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderSourceFile)) {
        
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderSourceFile)]];
    }
    if (JEEnumBitmasked(logMessageHeaderMask, JELogMessageHeaderFunction)) {
        
        [messageHeader appendString:logMessageHeaderEntries[@(JELogMessageHeaderFunction)]];
    }
    
    if ([messageHeader length] > 0) {
        
        [messageHeader appendString:@"\n"];
    }
    
    return messageHeader;
}

- (NSFileHandle *)cachedFileHandleWithThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings {
    
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSFileHandle *fileHandle = self.fileLogHandle;
    if (fileHandle) {
        
        return fileHandle;
    }
    
    if (self.fileLogIsDisabled) {
        
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
        self.fileLogIsDisabled = YES;
        
    };
    
    NSURL *fileURL = self.fileLogURL;
    if (!fileURL) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *fileLogsDirectoryURL = fileLoggerSettings.fileLogsDirectoryURL;
        NSError *directoryCreateError;
        if (![fileManager
              createDirectoryAtURL:fileLogsDirectoryURL
              withIntermediateDirectories:YES
              attributes:nil
              error:&directoryCreateError]) {
            
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
        if (![fileManager fileExistsAtPath:filePath]) {
            
            if (![fileManager createFileAtPath:filePath contents:nil attributes:nil]) {
                
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
              error:&attributeError]) {
            
            failure(JELogLocationCurrent(),
                    @"Failed to attach extended attribute to log file because of error:",
                    attributeError);
            return nil;
        }
        
        self.fileLogURL = fileURL;
    }
    
    NSString *attributeString;
    NSError *attributeError;
    if (![fileURL
          getExtendedAttribute:&attributeString
          forKey:_JEDebuggingFileLogAttributeKey
          error:&attributeError]) {
        
        failure(JELogLocationCurrent(),
                @"Failed to read extended attribute from log file because of error:",
                attributeError);
        return nil;
    }
    
    if (![_JEDebuggingFileLogAttributeValue isEqualToString:attributeString]) {
        
        failure(JELogLocationCurrent(),
                @"Extended attribute read from log file is incorrect.",
                nil);
        return nil;
    }
    
    NSError *fileHandleError;
    fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&fileHandleError];
    if (!fileHandle) {
        
        failure(JELogLocationCurrent(),
                @"Failed to open log file handle because of error:",
                fileHandleError);
        return nil;
    }
    
    [fileHandle seekToEndOfFile];
    
    self.fileLogHandle = fileHandle;
    self.fileLogLastSynchronizedOffset = [fileHandle offsetInFile];
    
    [self deleteOldFileLogsWithThreadSafeSettings:fileLoggerSettings];
    
    return fileHandle;
}

- (void)enumerateFileLogsWithThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings
                                          block:(void (^)(NSURL *fileURL, BOOL *stop))block {
    
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
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
    if (!fileURLs) {
        
        [JEDebugging
         logFileError:fileEnumerationError
         location:JELogLocationCurrent()
         message:@"Failed enumerating log files because of exception:"];
        return;
    }
    
    fileURLs = [fileURLs
                sortedArrayUsingDescriptors:@[[NSSortDescriptor
                                               sortDescriptorWithKey:JEKeypath(NSURL *, path)
                                               ascending:NO]]];
    
    [fileURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            NSNumber *isRegularFile;
            [fileURL
             getResourceValue:&isRegularFile
             forKey:(__bridge NSString *)kCFURLIsRegularFileKey
             error:NULL];
            if (![isRegularFile boolValue]) {
                
                return;
            }
            
            NSString *extendedAttribute;
            [fileURL
             getExtendedAttribute:&extendedAttribute
             forKey:_JEDebuggingFileLogAttributeKey
             error:NULL];
            if (![_JEDebuggingFileLogAttributeValue isEqualToString:extendedAttribute]) {
                
                return;
            }
            
            block(fileURL, stop);
            
        }
        
    }];
}

- (void)deleteOldFileLogsWithThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings {
    
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSURL *currentFileURL = self.fileLogURL;
    if (!currentFileURL) {
        
        return;
    }
    
    NSDateComponents *dayAgo = [[NSDateComponents alloc] init];
    [dayAgo setDay:-fileLoggerSettings.numberOfDaysBeforeDeletingFile];
    
    NSDate *earliestAllowedDate = [[NSCalendar gregorianCalendar]
                                   dateByAddingComponents:dayAgo
                                   toDate:[[NSDate alloc] init]
                                   options:kNilOptions];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self enumerateFileLogsWithThreadSafeSettings:fileLoggerSettings block:^(NSURL *fileURL, BOOL *stop) {
        
        if ([fileURL isEqual:currentFileURL]) {
            
            return;
        }
        
        NSDate *creationDate;
        [fileURL
         getResourceValue:&creationDate
         forKey:(__bridge NSString *)kCFURLCreationDateKey
         error:NULL];
        
        if ([creationDate compare:earliestAllowedDate] != NSOrderedAscending) {
            
            return;
        }
        
        [fileManager removeItemAtURL:fileURL error:NULL];
        
    }];
}

- (void)appendStringToFile:(NSString *)string
    withThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings {
    
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
                 withThreadSafeSettings:(JEFileLoggerSettings *)fileLoggerSettings {
    
    NSCAssert(dispatch_get_specific(_JEDebuggingQueueIDKey) == _JEDebuggingFileLogQueueID,
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    NSFileHandle *fileHandle = self.fileLogHandle;
    if (!fileHandle) {
        
        return;
    }
    
    unsigned long long offsetInFile = [fileHandle offsetInFile];
    unsigned long long lastSynchronizedOffset = self.fileLogLastSynchronizedOffset;
    
    if (offsetInFile == lastSynchronizedOffset) {
        
        return;
    }
    
    if (forceSave
        || (offsetInFile - lastSynchronizedOffset) >= fileLoggerSettings.numberOfBytesInMemoryBeforeWritingToFile) {
        
        [fileHandle synchronizeFile];
        self.fileLogLastSynchronizedOffset = offsetInFile;
    }
}

- (void)moveHUDLoggerToKeyWindowIfNeededWithThreadSafeSettings:(JEHUDLoggerSettings *)HUDLoggerSettings {
    
    NSCAssert([NSThread isMainThread],
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    JEHUDLogView *view = self.HUDLogView;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!view) {
        
        view = [[JEHUDLogView alloc]
                initWithFrame:[keyWindow
                               convertRect:[UIScreen mainScreen].bounds
                               fromWindow:nil]
                threadSafeSettings:HUDLoggerSettings];
        self.HUDLogView = view;
    }
    if (view.window != keyWindow) {
        
        [view removeFromSuperview];
        view.frame = keyWindow.frame;
        [keyWindow addSubview:view];
    }
}

- (void)appendStringToHUD:(NSString *)string
   withThreadSafeSettings:(JEHUDLoggerSettings *)HUDLoggerSettings {
    
    NSCAssert([NSThread isMainThread],
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    [self moveHUDLoggerToKeyWindowIfNeededWithThreadSafeSettings:HUDLoggerSettings];
    [self.HUDLogView addLogString:string withThreadSafeSettings:HUDLoggerSettings];
}


#pragma mark @selector

- (void)applicationWillResignActive:(NSNotification *)note {
    
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_async([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
    
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
    });
}

- (void)applicationWillTerminate:(NSNotification *)note {
    
    JEFileLoggerSettings *fileLoggerSettings = [JEDebugging copyFileLoggerSettings];
    dispatch_barrier_sync([JEDebugging fileLogQueue], ^{
        
        [self flushFileHandleIfNeededOrForced:YES withThreadSafeSettings:fileLoggerSettings];
        
    });
}

- (void)windowDidBecomeKeyWindow:(NSNotification *)note {
    
    NSCAssert([NSThread isMainThread], @"UIApplication's keyWindow was set on a background thread.");
    
    JEHUDLogView *view = self.HUDLogView;
    if (!view) {
        
        return;
    }
    
    if (view.window == [UIApplication sharedApplication].keyWindow) {
        
        return;
    }
    
    JEHUDLoggerSettings *__block HUDLoggerSettings;
    dispatch_barrier_sync([JEDebugging settingsQueue], ^{
        
        HUDLoggerSettings = self.HUDLoggerSettings;
        
    });
    
    [self moveHUDLoggerToKeyWindowIfNeededWithThreadSafeSettings:HUDLoggerSettings];
}


#pragma mark - Public

#pragma mark utilities

+ (BOOL)isDebugBuild {
    
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)isDebuggerRunning {
    
#ifdef DEBUG
    
    // https://developer.apple.com/library/mac/qa/qa1361/_index.html
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid() };
    
    struct kinfo_proc info = { .kp_proc.p_flag = 0 };
    size_t infoSize = sizeof(info);
    if (noErr == sysctl(mib, (sizeof(mib) / sizeof(*mib)), &info, &infoSize, NULL, 0)) {
        
        return JEEnumBitmasked(info.kp_proc.p_flag, P_TRACED);
    }
    
    return NO;
    
#else
    
    return NO;
    
#endif
}

#pragma mark configuring

+ (JEConsoleLoggerSettings *)copyConsoleLoggerSettings {
    
    JEConsoleLoggerSettings *__block settings;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].consoleLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setConsoleLoggerSettings:(JEConsoleLoggerSettings *)consoleLoggerSettings {
    
    JEAssertParameter(consoleLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLoggerSettings = [consoleLoggerSettings copy];
        
    });
}

+ (JEHUDLoggerSettings *)copyHUDLoggerSettings {
    
    JEHUDLoggerSettings *__block settings;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].HUDLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setHUDLoggerSettings:(JEHUDLoggerSettings *)HUDLoggerSettings {
    
    JEAssertParameter(HUDLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLoggerSettings = [HUDLoggerSettings copy];
        
    });
}

+ (JEFileLoggerSettings *)copyFileLoggerSettings {
    
    JEFileLoggerSettings *__block settings;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        settings = [[self sharedInstance].fileLoggerSettings copy];
        
    });
    return settings;
}

+ (void)setFileLoggerSettings:(JEFileLoggerSettings *)fileLoggerSettings {
    
    JEAssertParameter(fileLoggerSettings != nil);
    
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].fileLoggerSettings = [fileLoggerSettings copy];
        
    });
}

+ (void)start {
    
    [self sharedInstance].isStarted = YES;
    
    [self
     logLevel:JELogLevelNotice
     location:(JELogLocation){ NULL, NULL, 0 }
     format:@"Debugging session started."];
}

#pragma mark logging

+ (void)dumpLevel:(JELogLevelMask)level
         location:(JELogLocation)location
            label:(NSString *)label
            value:(NSValue *)wrappedValue {
    
    if (![self sharedInstance].isStarted) {
        
        return;
    }
    
    @autoreleasepool {
        
        JEConsoleLoggerSettings *__block consoleLoggerSettings;
        JEHUDLoggerSettings *__block HUDLoggerSettings;
        JEFileLoggerSettings *__block fileLoggerSettings;
        dispatch_barrier_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLoggerSettings = instance.consoleLoggerSettings;
            HUDLoggerSettings = instance.HUDLoggerSettings;
            fileLoggerSettings = instance.fileLoggerSettings;
            
        });
        
        if (!JEEnumBitmasked(consoleLoggerSettings.logLevelMask, level)
            && !JEEnumBitmasked(HUDLoggerSettings.logLevelMask, level)
            && !JEEnumBitmasked(fileLoggerSettings.logLevelMask, level)) {
            
            return;
        }
        
        // Note that because of a bug(?) with NSGetSizeAndAlignment, structs and unions with bitfields cannot be wrapped in NSValue, in which case wrappedValue will be nil.
        NSMutableString *description = [NSMutableString stringWithString:
                                        (wrappedValue
                                         ? [wrappedValue
                                            loggingDescriptionIncludeClass:NO
                                            includeAddress:NO]
                                         : @"(?) { ... }")];
        [description indentByLevel:1];
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLocation:location
                                       withMask:(consoleLoggerSettings.logMessageHeaderMask
                                                 | HUDLoggerSettings.logMessageHeaderMask
                                                 | fileLoggerSettings.logMessageHeaderMask)];
        NSString *bulletString;
        if (JEEnumBitmasked(level, JELogLevelAlert)) {
            
            bulletString = [self defaultAlertBulletString];
        }
        else if (JEEnumBitmasked(level, JELogLevelNotice)) {
            
            bulletString = [self defaultLogBulletString];
        }
        else {
            
            bulletString = [self defaultTraceBulletString];
        }
        
        if (JEEnumBitmasked(consoleLoggerSettings.logLevelMask, level)) {
            
            dispatch_barrier_sync([self consoleLogQueue], ^{
                
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
        if (JEEnumBitmasked(HUDLoggerSettings.logLevelMask, level)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:HUDLoggerSettings];
                    [logString appendFormat:@"%@ %@\n  %@ %@",
                     bulletString, label, [self defaultDumpBulletString], description];
                    
                    [[self sharedInstance]
                     appendStringToHUD:logString
                     withThreadSafeSettings:HUDLoggerSettings];
                    
                }
                
            });
        }
        if (JEEnumBitmasked(fileLoggerSettings.logLevelMask, level)) {
            
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
          format:(NSString *)format, ... {
    
    if (![self sharedInstance].isStarted) {
        
        return;
    }
    
    @autoreleasepool {
        
        JEConsoleLoggerSettings *__block consoleLoggerSettings;
        JEHUDLoggerSettings *__block HUDLoggerSettings;
        JEFileLoggerSettings *__block fileLoggerSettings;
        dispatch_barrier_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLoggerSettings = instance.consoleLoggerSettings;
            HUDLoggerSettings = instance.HUDLoggerSettings;
            fileLoggerSettings = instance.fileLoggerSettings;
            
        });
        
        if (!JEEnumBitmasked(consoleLoggerSettings.logLevelMask, level)
            && !JEEnumBitmasked(HUDLoggerSettings.logLevelMask, level)
            && !JEEnumBitmasked(fileLoggerSettings.logLevelMask, level)) {
            
            return;
        }
        
        va_list arguments;
        va_start(arguments, format);
        NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLocation:location
                                       withMask:(consoleLoggerSettings.logMessageHeaderMask
                                                 | HUDLoggerSettings.logMessageHeaderMask
                                                 | fileLoggerSettings.logMessageHeaderMask)];
        NSString *bulletString;
        if (JEEnumBitmasked(level, JELogLevelAlert)) {
            
            bulletString = [self defaultAlertBulletString];
        }
        else if (JEEnumBitmasked(level, JELogLevelNotice)) {
            
            bulletString = [self defaultLogBulletString];
        }
        else {
            
            bulletString = [self defaultTraceBulletString];
        }
        
        if (JEEnumBitmasked(consoleLoggerSettings.logLevelMask, level)) {
            
            dispatch_barrier_sync([self consoleLogQueue], ^{
                
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
        if (JEEnumBitmasked(HUDLoggerSettings.logLevelMask, level)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:HUDLoggerSettings];
                    [logString appendFormat:@"%@ %@",
                     bulletString, formattedString];
                    
                    [[self sharedInstance]
                     appendStringToHUD:logString
                     withThreadSafeSettings:HUDLoggerSettings];
                    
                }
                
            });
        }
        if (JEEnumBitmasked(fileLoggerSettings.logLevelMask, level)) {
            
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

+ (void)logFailureInAssertionCondition:(NSString *)conditionString
                              location:(JELogLocation)location {
    
    if (![self sharedInstance].isStarted) {
        
        return;
    }
    
    @autoreleasepool {
        
        JEConsoleLoggerSettings *__block consoleLoggerSettings;
        JEHUDLoggerSettings *__block HUDLoggerSettings;
        JEFileLoggerSettings *__block fileLoggerSettings;
        dispatch_barrier_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLoggerSettings = instance.consoleLoggerSettings;
            HUDLoggerSettings = instance.HUDLoggerSettings;
            fileLoggerSettings = instance.fileLoggerSettings;
            
        });
        
        if (!JEEnumBitmasked(consoleLoggerSettings.logLevelMask, JELogLevelAlert)
            && !JEEnumBitmasked(HUDLoggerSettings.logLevelMask, JELogLevelAlert)
            && !JEEnumBitmasked(fileLoggerSettings.logLevelMask, JELogLevelAlert)) {
            
            return;
        }
        
        NSDictionary *headerEntries = [self
                                       headerEntriesForLocation:location
                                       withMask:(consoleLoggerSettings.logMessageHeaderMask
                                                 | HUDLoggerSettings.logMessageHeaderMask
                                                 | fileLoggerSettings.logMessageHeaderMask)];
        NSString *bulletString = [self defaultAssertBulletString];
        NSString *formattedString = [[NSString alloc] initWithFormat:
                                     @"Assertion failed for condition: (%@)",
                                     conditionString];
        
        if (JEEnumBitmasked(consoleLoggerSettings.logLevelMask, JELogLevelAlert)) {
            
            dispatch_barrier_sync([self consoleLogQueue], ^{
                
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
        if (JEEnumBitmasked(HUDLoggerSettings.logLevelMask, JELogLevelAlert)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @autoreleasepool {
                    
                    NSMutableString *logString = [self
                                                  messageHeaderFromEntries:headerEntries
                                                  withSettings:HUDLoggerSettings];
                    [logString appendFormat:@"%@ %@",
                     bulletString, formattedString];
                    
                    [[self sharedInstance]
                     appendStringToHUD:logString
                     withThreadSafeSettings:HUDLoggerSettings];
                    
                }
                
            });
        }
        if (JEEnumBitmasked(fileLoggerSettings.logLevelMask, JELogLevelAlert)) {
            
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

#pragma mark retrieving

+ (void)enumerateFileLogsWithBlock:(void (^)(NSString *fileName, NSData *data, BOOL *stop))block {
    
    JEAssert(block != NULL, @"Enumeration block was NULL.");
    
    JEFileLoggerSettings *__block fileLoggerSettings;
    dispatch_barrier_sync([JEDebugging settingsQueue], ^{
        
        fileLoggerSettings = [self sharedInstance].fileLoggerSettings;
        
    });
    
    dispatch_barrier_sync([self fileLogQueue], ^{
        
        [[self sharedInstance] enumerateFileLogsWithThreadSafeSettings:fileLoggerSettings block:^(NSURL *fileURL, BOOL *stop) {
            
            NSData *data = [[NSData alloc]
                            initWithContentsOfURL:fileURL
                            options:kNilOptions
                            error:NULL];
            if (!data) {
                
                return;
            }
            
            BOOL shouldStop = NO;
            block([fileURL lastPathComponent], data, &shouldStop);
            if (shouldStop) {
                
                (*stop) = YES;
            }
            
        }];
        
    });
}


@end
