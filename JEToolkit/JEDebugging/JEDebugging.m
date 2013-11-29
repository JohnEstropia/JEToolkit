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

#import "JEConsoleHUD.h"


@interface JEDebugging ()

@property (nonatomic, assign) JEConsoleLogHeaderMask consoleLogHeaderMask;
@property (nonatomic, assign) JEConsoleLogHeaderMask HUDLogHeaderMask;
@property (nonatomic, assign) JEConsoleLogHeaderMask fileLogHeaderMask;
@property (nonatomic, assign) JELogLevelMask consoleLogLevelMask;
@property (nonatomic, assign) JELogLevelMask HUDLogLevelMask;
@property (nonatomic, assign) JELogLevelMask fileLogLevelMask;
@property (nonatomic, copy) NSString *traceBulletString;
@property (nonatomic, copy) NSString *logBulletString;
@property (nonatomic, copy) NSString *dumpBulletString;
@property (nonatomic, copy) NSString *alertBulletString;
@property (nonatomic, weak) JEConsoleHUD *consoleHUD;

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
    
    return self;
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

+ (dispatch_queue_t)consoleQueue
{
    static dispatch_queue_t consoleQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        consoleQueue = dispatch_queue_create("JEDebugging.consoleQueue", DISPATCH_QUEUE_CONCURRENT);
        
    });
    return consoleQueue;
}

+ (dispatch_queue_t)settingsQueue
{
    static dispatch_queue_t settingsQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        settingsQueue = dispatch_queue_create("JEDebugging.settingsQueue", DISPATCH_QUEUE_CONCURRENT);
        
    });
    return settingsQueue;
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

+ (NSMutableString *)stringForlogHeader:(JELogHeader)header
                               withMask:(JEConsoleLogHeaderMask)mask
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    if (IsEnumBitSet(mask, JEConsoleLogHeaderDate))
    {
        [string appendFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderQueue))
    {
        [string appendFormat:@"[%s] ", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderFile)
        && header.fileName != NULL
        && header.lineNumber > 0)
    {
        [string appendFormat:
         @"%s:%li ",
         header.fileName,
         (long)header.lineNumber];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderFunction)
        && header.functionName != NULL)
    {
        [string appendFormat:@"%s ", header.functionName];
    }
    
    if ([string length] > 0)
    {
        [string appendString:@"\n"];
    }
    
    return string;
}


#pragma mark - Public

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

#pragma mark bullet settings

+ (void)setDumpBulletString:(NSString *)dumpBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].dumpBulletString = dumpBulletString;
        
    });
}

+ (void)setTraceBulletString:(NSString *)traceBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].traceBulletString = traceBulletString;
        
    });
}

+ (void)setLogBulletString:(NSString *)logBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].logBulletString = logBulletString;
        
    });
}

+ (void)setAlertBulletString:(NSString *)alertBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].alertBulletString = alertBulletString;
        
    });
}

#pragma mark logging

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header
{
    @autoreleasepool {
        
        JEConsoleLogHeaderMask __block consoleLogHeaderMask;
        JEConsoleLogHeaderMask __block HUDLogHeaderMask;
        JEConsoleLogHeaderMask __block fileLogHeaderMask;
        JELogLevelMask __block consoleLogLevelMask;
        JELogLevelMask __block HUDLogLevelMask;
        JELogLevelMask __block fileLogLevelMask;
        NSString *__block logBulletString;
        NSString *__block dumpBulletString;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            fileLogHeaderMask = instance.fileLogHeaderMask;
            
            consoleLogLevelMask = instance.consoleLogLevelMask;
            HUDLogLevelMask = instance.HUDLogLevelMask;
            fileLogLevelMask = instance.fileLogLevelMask;
            
            logBulletString = (instance.traceBulletString ?: [self defaultTraceBulletString]);
            dumpBulletString = (instance.dumpBulletString ?: [self defaultDumpBulletString]);
            
        });
        
        if (!IsEnumBitSet(consoleLogLevelMask, JELogLevelTrace)
            && !IsEnumBitSet(HUDLogLevelMask, JELogLevelTrace)
            && !IsEnumBitSet(fileLogLevelMask, JELogLevelTrace))
        {
            return;
        }
        
        // Note that because of a bug(?) with NSGetSizeAndAlignment, structs and unions with bitfields cannot be wrapped in NSValue, in which case wrappedValue will be nil.
        NSMutableString *description = (wrappedValue
                                        ? [wrappedValue detailedDescriptionIncludeClass:NO includeAddress:NO]
                                        : [[NSMutableString alloc] initWithString:@"(?) { ... }"]);
        [description indentByLevel:1];
        
        if (IsEnumBitSet(consoleLogLevelMask, JELogLevelTrace))
        {
            dispatch_sync([self consoleQueue], ^{
                
                NSMutableString *consoleString = [self
                                                  stringForlogHeader:header
                                                  withMask:consoleLogHeaderMask];
                [consoleString appendString:logBulletString];
                [consoleString appendString:@" "];
                [consoleString appendString:label];
                [consoleString appendString:@"\n  "];
                [consoleString appendString:dumpBulletString];
                [consoleString appendString:@" "];
                [consoleString appendString:description];
                [consoleString appendString:@"\n"];
                
                puts([consoleString UTF8String]);
                
            });
        }
        if (IsEnumBitSet(HUDLogLevelMask, JELogLevelTrace))
        {
            NSMutableString *HUDString = [self
                                          stringForlogHeader:header
                                          withMask:HUDLogHeaderMask];
        }
        if (IsEnumBitSet(fileLogLevelMask, JELogLevelTrace))
        {
            NSMutableString *fileString = [self
                                           stringForlogHeader:header
                                           withMask:fileLogHeaderMask];
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
        NSString *__block bulletString;
        dispatch_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            fileLogHeaderMask = instance.fileLogHeaderMask;
            
            consoleLogLevelMask = instance.consoleLogLevelMask;
            HUDLogLevelMask = instance.HUDLogLevelMask;
            fileLogLevelMask = instance.fileLogLevelMask;
            
            if (IsEnumBitSet(level, JELogLevelAlert))
            {
                bulletString = (instance.alertBulletString ?: [self defaultAlertBulletString]);
            }
            else if (IsEnumBitSet(level, JELogLevelNotice))
            {
                bulletString = (instance.logBulletString ?: [self defaultLogBulletString]);
            }
            else
            {
                bulletString = (instance.traceBulletString ?: [self defaultTraceBulletString]);
            }
            
        });
        
        if (IsEnumBitSet(consoleLogLevelMask, level))
        {
            dispatch_sync([self consoleQueue], ^{
                
                NSMutableString *consoleString = [self
                                                  stringForlogHeader:header
                                                  withMask:consoleLogHeaderMask];
                [consoleString appendString:bulletString];
                [consoleString appendString:@" "];
                [consoleString appendString:formattedString];
                [consoleString appendString:@"\n"];
                
                puts([consoleString UTF8String]);
                
            });
        }
        if (IsEnumBitSet(HUDLogLevelMask, level))
        {
            NSMutableString *HUDString = [self
                                          stringForlogHeader:header
                                          withMask:HUDLogHeaderMask];
        }
        if (IsEnumBitSet(fileLogLevelMask, level))
        {
            NSMutableString *fileString = [self
                                           stringForlogHeader:header
                                           withMask:fileLogHeaderMask];
        }
        
    }
}


@end
