//
//  JEDebugging.h
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

#import <Foundation/Foundation.h>

#import "NSArray+JEDebugging.h"
#import "NSDate+JEDebugging.h"
#import "NSDictionary+JEDebugging.h"
#import "NSError+JEDebugging.h"
#import "NSException+JEDebugging.h"
#import "NSHashTable+JEDebugging.h"
#import "NSMapTable+JEDebugging.h"
#import "NSMutableString+JEDebugging.h"
#import "NSNumber+JEDebugging.h"
#import "NSObject+JEDebugging.h"
#import "NSOrderedSet+JEDebugging.h"
#import "NSPointerArray+JEDebugging.h"
#import "NSSet+JEDebugging.h"
#import "NSString+JEDebugging.h"
#import "NSValue+JEDebugging.h"
#import "UIColor+JEDebugging.h"
#import "UIImage+JEDebugging.h"

#import "JECompilerDefines.h"

#import "JEConsoleLoggerSettings.h"
#import "JEHUDLoggerSettings.h"
#import "JEFileLoggerSettings.h"



#pragma mark - JEAssert() variants

#ifdef NS_BLOCK_ASSERTIONS

#define JEAssert(condition, formatString, ...)  do {} while (NO)
#define JEAssertParameter(condition)            do {} while (NO)
#define JEAssertMainThread()                    do {} while (NO)
#define JEAssertBackgroundThread()              do {} while (NO)
#define JEAssertMethodOverride()                do {} while (NO)

#else

#define JEAssert(condition, formatString, ...) \
    do { \
        if (!(condition)) { \
            [JEDebugging \
             logFailureInAssertionCondition:@"" #condition \
             location:JELogLocationCurrent()]; \
            JE_PRAGMA_PUSH \
            JE_PRAGMA_IGNORE("-Wformat-extra-args") \
            [NSException \
             raise:NSInternalInconsistencyException \
             format:(formatString), ##__VA_ARGS__]; \
            JE_PRAGMA_POP \
        } \
    } while(NO)

#define JEAssertParameter(condition) \
    JEAssert((condition), @"Invalid parameter not satisfying: (%s)", #condition)

#define JEAssertMainThread() \
    JEAssert([NSThread isMainThread], @"Code expected to run on the main thread")

#define JEAssertBackgroundThread() \
    JEAssert(![NSThread isMainThread], @"Code expected to run on a background thread")

#define JEAssertMethodOverride() \
    do { \
        NSString *formatString = [NSString stringWithFormat:@"Required method %s override not implemented.", __PRETTY_FUNCTION__];\
        [JEDebugging \
         logFailureInAssertionWithMessage:formatString \
         location:JELogLocationCurrent()]; \
        JE_PRAGMA_PUSH \
        JE_PRAGMA_IGNORE("-Wformat-extra-args") \
        [NSException \
         raise:NSInternalInconsistencyException \
         format:@"%@", formatString]; \
        JE_PRAGMA_POP \
    } while(NO)



#endif



#pragma mark - JEDump() variants

/*! Dumps detailed information of any variable or expression to the console.
 
 The macro argument is variadic to allow expressions that have commas in them. You can use this as a trick to use the comma operator to attach a string before the expression, such as JEDump("This will be 2", 1+1); Be warned though that if you are using the comma operator for arrays you need to pass the address instead: JEDump("This is safe", &arrayVariable);
 Otherwise, only the first item in the array will be printed (or crash if you passed an empty array).
 
 Note that a bug(?) with NSGetSizeAndAlignment() prevents structs and unions with bitfields to be wrapped in NSValue, in which case JEDump() will just print "(?){ ... }".
 */
#define JEDump(expression...) \
    JEDumpLevel(JELogLevelTrace, ##expression)

#define JEDumpTrace(expression...) \
    JEDumpLevel(JELogLevelTrace, ##expression)

#define JEDumpNotice(expression...) \
    JEDumpLevel(JELogLevelNotice, ##expression)

#define JEDumpAlert(expression...) \
    JEDumpLevel(JELogLevelAlert, ##expression)

#define JEDumpFatal(expression...) \
    JEDumpLevel(JELogLevelFatal, ##expression)

#define JEDumpLevel(level, expression...) \
    do { \
        JE_PRAGMA_PUSH \
        JE_PRAGMA_IGNORE("-Wunused-value") \
        /* We need to assign the expression to a variable in case it is an rvalue. */ \
        /* Since arrays cannot be assigned to another array, we use the comma operator in typeof(0, expression) to demote array types to their pointer counterparts. */ \
        const typeof(0, expression) _je_value = (expression); \
        JE_PRAGMA_POP \
        [JEDebugging \
         dumpLevel:level \
         location:JELogLocationCurrent() \
         label:(@""#expression) \
         value:[NSValue \
                valueWithBytes:({ \
                    /* We need to get the proper address to pass to NSValue. That is, if an array we need to pass itself, otherwise its address. Hopefully, this all gets optimized out by the compiler. */ \
                    const void *const _je_pointer = &_je_value; \
                    (@encode(typeof(expression))[0] == '[' \
                        ? *(const void *const *)_je_pointer \
                        : _je_pointer); \
                }) \
                objCType:@encode(typeof(expression))]]; \
    } while(NO)



#pragma mark - JELog() variants

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JELog(formatString, ...) \
    JELogLevel(JELogLevelTrace, (formatString), ##__VA_ARGS__)

#define JELogTrace(formatString, ...) \
    JELogLevel(JELogLevelTrace, (formatString), ##__VA_ARGS__)

#define JELogNotice(formatString, ...) \
    JELogLevel(JELogLevelNotice, (formatString), ##__VA_ARGS__)

#define JELogAlert(formatString, ...) \
    JELogLevel(JELogLevelAlert, (formatString), ##__VA_ARGS__)

#define JELogFatal(formatString, ...) \
    JELogLevel(JELogLevelFatal, (formatString), ##__VA_ARGS__)

#define JELogLevel(level, formatString, ...) \
    do { \
        JE_PRAGMA_PUSH \
        JE_PRAGMA_IGNORE("-Wformat-extra-args") \
        [JEDebugging \
         logLevel:level \
         location:JELogLocationCurrent() \
         logMessage:^{ return [[NSString alloc] initWithFormat:(formatString), ##__VA_ARGS__]; }]; \
        JE_PRAGMA_POP \
    } while(NO)



#pragma mark - Log message header constants container

typedef struct JELogLocation {

    const char *_Nullable fileName;
    const char *_Nullable functionName;
    const unsigned int lineNumber;

} JELogLocation;

#define JELogLocationCurrent()  ((JELogLocation){ __JE_FILE_NAME__, __PRETTY_FUNCTION__, __LINE__ })



#pragma mark - JEDebugging class

/*! @p JEDebugging is the central hub for configuring, submitting, and extracting logs.
 */
@interface JEDebugging : NSObject

#pragma mark - utilities

/*! Provides the value of the @p DEBUG preprocessor flag during runtime.
 @return @p YES if the @p DEBUG flag is set, @p NO otherwise.
 */
+ (BOOL)isDebugBuild;

/*! Checks if the debugger is currently attached to the app.
 @return @p YES if the debugger is attached to the running app process, @p NO otherwise.
 */
+ (BOOL)isDebuggerAttached;


#pragma mark - configuring

/*! Returns a configurable copy of the current console logger settings.
 @return a configurable copy of the current console logger settings. The changes to the returned object will not be reflected until it is passed back to @p setConsoleLoggerSettings:
 */
+ (nonnull JEConsoleLoggerSettings *)copyConsoleLoggerSettings JE_WARN_UNUSED_RESULT;

/*! Updates the current console logger settings. Note that the settings object passed to this method will be copied by the receiver, thus, further changes to the settings object will not be reflected until it is again passed to @p setConsoleLoggerSettings:
 @param consoleLoggerSettings the settings object holding new configuration values
 */
+ (void)setConsoleLoggerSettings:(nonnull JEConsoleLoggerSettings *)consoleLoggerSettings;

/*! Returns a configurable copy of the current HUD logger settings.
 @return a configurable copy of the current HUD logger settings. The changes to the returned object will not be reflected until it is passed back to @p setHUDLoggerSettings:
 */
+ (nonnull JEHUDLoggerSettings *)copyHUDLoggerSettings JE_WARN_UNUSED_RESULT;

/*! Updates the current HUD logger settings. Note that the settings object passed to this method will be copied by the receiver, thus, further changes to the settings object will not be reflected until it is again passed to @p setHUDLoggerSettings:
 @param HUDLoggerSettings the settings object holding new configuration values
 */
+ (void)setHUDLoggerSettings:(nonnull JEHUDLoggerSettings *)HUDLoggerSettings;

/*! Returns a configurable copy of the current file logger settings.
 @return a configurable copy of the current file logger settings. The changes to the returned object will not be reflected until it is passed back to @p setFileLoggerSettings:
 */
+ (nonnull JEFileLoggerSettings *)copyFileLoggerSettings JE_WARN_UNUSED_RESULT;

/*! Updates the current file logger settings. Note that the settings object passed to this method will be copied by the receiver, thus, further changes to the settings object will not be reflected until it is again passed to @p setFileLoggerSettings:
 @param fileLoggerSettings the settings object holding new configuration values
 */
+ (void)setFileLoggerSettings:(nonnull JEFileLoggerSettings *)fileLoggerSettings;

/*! Enable or disable exception logging. Note that setting enabled to @p YES will detach the previously set exception handler, such as handlers provided by analytics frameworks or other debugging frameworks.
 @param enabled @p YES to enable exception logging and detach the previous exception handler; @p NO to disable exception logging and restore the original exception handler. Defaults to @p NO.
 */
+ (void)setExceptionLoggingEnabled:(BOOL)enabled;

/*! Enable or disable application lifecycle logging (JELogLevelTrace level). Logged events include foreground and background events, active and inactive events, and UIViewController viewDidAppear and viewWillDisappear events.
 @param enabled @p YES to enable application lifecycle logging, @p NO to disable. Defaults to @p NO.
 */
+ (void)setApplicationLifeCycleLoggingEnabled:(BOOL)enabled;

/*!
 Starts the logging session. All logs are ignored until this method is called.
 */
+ (void)start;


#pragma mark - logging

/*!
 Use the @p JEDump(...) family of utilities instead of this method.
 */
+ (void)dumpLevel:(JELogLevelMask)level
         location:(JELogLocation)location
            label:(nonnull NSString *)label
            value:(nullable NSValue *)wrappedValue;

/*!
 Use the @p JEDump(...) family of utilities instead of this method.
 */
+ (void)dumpLevel:(JELogLevelMask)level
         location:(JELogLocation)location
            label:(nonnull NSString *)label
 valueDescription:(nonnull id _Nonnull(^__attribute__((noescape)))(void))valueDescription;

/*!
 Use the @p JELog(...) family of utilities instead of this method.
 */
+ (void)logLevel:(JELogLevelMask)level
        location:(JELogLocation)location
          format:(nonnull NSString *)format, ... JE_FORMAT_STRING(3, 4);

/*!
 Use the @p JELog(...) family of utilities instead of this method.
 */
+ (void)logLevel:(JELogLevelMask)level
        location:(JELogLocation)location
      logMessage:(nonnull id _Nonnull(^__attribute__((noescape)))(void))logMessage;


/*!
 Use the @p JEAssert(...) family of utilities instead of this method.
 */
+ (void)logFailureInAssertionCondition:(nonnull NSString *)conditionString
                              location:(JELogLocation)location;

/*!
 Use the @p JEAssert(...) family of utilities instead of this method.
 */
+ (void)logFailureInAssertionWithMessage:(nonnull NSString *)failureMessage
                                location:(JELogLocation)location;

/*!
 Use the @p setApplicationLifeCycleLoggingEnabled: to enable application lifecycle logging instead of this method.
 */
+ (void)logLifeCycleEventWithFormat:(nonnull NSString *)format, ... JE_FORMAT_STRING(1, 2);

/*!
 Use the @p setApplicationLifeCycleLoggingEnabled: to enable application lifecycle logging instead of this method.
 */
+ (void)logLifeCycleEventWithFormat:(nonnull NSString *)format
JE_PRAGMA_PUSH
JE_PRAGMA_IGNORE("-Wnullability-completeness")
                          arguments:(va_list)arguments;
JE_PRAGMA_POP


#pragma mark - retrieving

/*!
 Enumerates all log files' data synchronously, starting with the most recent up to the oldest file.
 @param block The iteration block. Set the @p stop argument to @p YES to terminate the enumeration.
 */
+ (void)enumerateFileLogDataWithBlock:(nonnull void (^)(NSString *_Nonnull fileName, NSData *_Nonnull data, BOOL *_Nonnull stop))block;

/*!
 Enumerates all log files' URLs synchronously, starting with the most recent up to the oldest file.
 @param block The iteration block. Set the @p stop argument to @p YES to terminate the enumeration.
 */
+ (void)enumerateFileLogURLsWithBlock:(nonnull void (^)(NSURL *_Nonnull fileURL, BOOL *_Nonnull stop))block;

@end
