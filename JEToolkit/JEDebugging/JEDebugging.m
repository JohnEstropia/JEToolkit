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
@property (nonatomic, copy) NSString *logBulletString;
@property (nonatomic, copy) NSString *dumpBulletString;
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
    
    _consoleLogHeaderMask = JEConsoleLogHeaderMaskDefault;
    _HUDLogHeaderMask = JEConsoleLogHeaderMaskDefault;
    _logBulletString = nil;
    _dumpBulletString = nil;
    
    
    return self;
}


#pragma mark - private

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

+ (NSString *)defaultLogBulletString
{
    return @"🔹";
}

+ (NSString *)defaultDumpBulletString
{
    return @"🔸";
}

+ (NSMutableString *)stringForlogHeader:(JELogHeader)header
                               withMask:(JEConsoleLogHeaderMask)mask
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskDate))
    {
        [string appendFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskQueue))
    {
        [string appendFormat:@"[%s] ", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    }
    
    if (header.sourceFile != NULL
        && header.functionName != NULL
        && header.lineNumber > 0)
    {
        if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskFile))
        {
            [string appendFormat:
             @"%s:%li ",
             ((strrchr(header.sourceFile, '/') ?: (header.sourceFile - 1)) + 1),
             (long)header.lineNumber];
        }
        if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskFunction))
        {
            [string appendFormat:@"%s ", header.functionName];
        }
    }
    
    if ([string length] > 0)
    {
        [string appendString:@"\n"];
    }
    
    return string;
}


#pragma mark - public

+ (BOOL)isHUDEnabled
{
    if ([NSThread isMainThread])
    {
        JEConsoleHUD *consoleHUD = [self sharedInstance].consoleHUD;
        return (consoleHUD.superview != nil);
    }
    
    BOOL __block isHUDEnabled = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        JEConsoleHUD *consoleHUD = [self sharedInstance].consoleHUD;
        isHUDEnabled = (consoleHUD.superview != nil);
        
    });
    
    return isHUDEnabled;
}

+ (void)setIsHUDEnabled:(BOOL)isHUDEnabled
{
    if ([NSThread isMainThread])
    {
#warning TODO: create view
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
#warning TODO: create view
        
    });
}

+ (JEConsoleLogHeaderMask)consoleLogHeaderMask
{
    JEConsoleLogHeaderMask __block consoleHeaderMask;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        consoleHeaderMask = [self sharedInstance].consoleLogHeaderMask;
        
    });
    return consoleHeaderMask;
}

+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLogHeaderMask = mask;
        
    });
}

+ (JEConsoleLogHeaderMask)HUDLogHeaderMask
{
    JEConsoleLogHeaderMask __block HUDLogHeaderMask;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        HUDLogHeaderMask = [self sharedInstance].HUDLogHeaderMask;
        
    });
    return HUDLogHeaderMask;
}

+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLogHeaderMask = mask;
        
    });
}

+ (NSString *)logBulletString
{
    NSString *__block logBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        logBulletString = [self sharedInstance].logBulletString;
        
    });
    return logBulletString;
}

+ (void)setLogBulletString:(NSString *)logBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].logBulletString = logBulletString;
        
    });
}

+ (NSString *)dumpBulletString
{
    NSString *__block dumpBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        dumpBulletString = [self sharedInstance].dumpBulletString;
        
    });
    return dumpBulletString;
}

+ (void)setDumpBulletString:(NSString *)dumpBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].dumpBulletString = dumpBulletString;
        
    });
}

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header
{
    @autoreleasepool {
        
        NSMutableString *description = [wrappedValue detailedDescriptionIncludeClass:NO includeAddress:NO];
        [description indentByLevel:1];
        
        JEConsoleLogHeaderMask __block consoleLogHeaderMask;
        JEConsoleLogHeaderMask __block HUDLogHeaderMask;
        NSString *__block logBulletString;
        NSString *__block dumpBulletString;
        dispatch_barrier_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            logBulletString = instance.logBulletString;
            dumpBulletString = instance.dumpBulletString;
            
        });
        
        NSMutableString *consoleString = [self
                                          stringForlogHeader:header
                                          withMask:consoleLogHeaderMask];
        [consoleString appendFormat:
         @"%@%@\n  %@%@\n",
         (logBulletString ?: [self defaultLogBulletString]),
         label,
         (dumpBulletString ?: [self defaultDumpBulletString]),
         description];
        
        dispatch_barrier_sync([self consoleQueue], ^{
            
            puts([consoleString UTF8String]);
            
        });
        
    }
}

+ (void)logFormat:(NSString *)format
           header:(JELogHeader)header, ...
{
    va_list arguments;
    va_start(arguments, header);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
    
    JEConsoleLogHeaderMask __block consoleLogHeaderMask;
    JEConsoleLogHeaderMask __block HUDLogHeaderMask;
    NSString *__block logBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        JEDebugging *instance = [self sharedInstance];
        consoleLogHeaderMask = instance.HUDLogHeaderMask;
        HUDLogHeaderMask = instance.HUDLogHeaderMask;
        logBulletString = instance.logBulletString;
        
    });
    
    NSMutableString *consoleString = [self
                                      stringForlogHeader:header
                                      withMask:consoleLogHeaderMask];
    [consoleString appendFormat:
     @"%@%@\n",
     (logBulletString ?: [self defaultLogBulletString]),
     formattedString];
    
    dispatch_barrier_sync([self consoleQueue], ^{
        
        puts([consoleString UTF8String]);
        
    });
}


@end
