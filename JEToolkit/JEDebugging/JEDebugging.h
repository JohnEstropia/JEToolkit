//
//  JEDebugging.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"
#import "NSObject+JEDebugging.h"

#import "JEConsoleLoggerSettings.h"
#import "JEHUDLoggerSettings.h"
#import "JEFileLoggerSettings.h"


#pragma mark - Log default masks

#ifndef JE_LOG_DEFAULT_LEVEL
    #define JE_LOG_DEFAULT_LEVEL    JELogLevelTrace
#endif

#ifndef JE_DUMP_DEFAULT_LEVEL
    #define JE_DUMP_DEFAULT_LEVEL   JELogLevelTrace
#endif


#pragma mark - Log message header constants container

typedef struct JELogLocation
{
    const char *fileName;
    const char *functionName;
    int lineNumber;
} JELogLocation;

#define JELogLocationCurrent()  ((JELogLocation){ \
                                    JE_LOG_LOCATION_FILENAME, \
                                    JE_LOG_LOCATION_FUNCTION_NAME, \
                                    JE_LOG_LOCATION_LINE_NUMBER })

#if defined(DEBUG) || JE_LOG_EMBED_FILENAME
    #define JE_LOG_LOCATION_FILENAME        __JE_FILE_NAME__
#else
    #define JE_LOG_LOCATION_FILENAME        NULL
#endif

#if defined(DEBUG) || JE_LOG_EMBED_FUNCTION_NAME
    #define JE_LOG_LOCATION_FUNCTION_NAME   __PRETTY_FUNCTION__
#else
    #define JE_LOG_LOCATION_FUNCTION_NAME   NULL
#endif

#if defined(DEBUG) || JE_LOG_EMBED_LINE_NUMBER
    #define JE_LOG_LOCATION_LINE_NUMBER     __LINE__
#else
    #define JE_LOG_LOCATION_LINE_NUMBER     0
#endif


#pragma mark - JEDump() variants

/*! Dumps detailed information of any variable or expression to the console.
 
 The macro argument is variadic to allow expressions that have commas in them. You can use this as a trick to use the comma operator to attach a string before the expression, such as JEDump("This will be 2", 1+1); Be warned though that if you are using the comma operator for arrays you need to pass the address instead: JEDump("This is safe", &arrayVariable);
 Otherwise, only the first item in the array will be printed (or crash if you passed an empty array).
 
 Note that a bug(?) with NSGetSizeAndAlignment() prevents structs and unions with bitfields to be wrapped in NSValue, in which case JEDump() will just print "(?){ ... }".
 */
#define JEDump(nonArrayExpression...) \
    JEDumpLevel(JE_DUMP_DEFAULT_LEVEL, ##nonArrayExpression)

#define JEDumpTrace(nonArrayExpression...) \
    JEDumpLevel(JELogLevelTrace, ##nonArrayExpression)

#define JEDumpNotice(nonArrayExpression...) \
    JEDumpLevel(JELogLevelNotice, ##nonArrayExpression)

#define JEDumpAlert(nonArrayExpression...) \
    JEDumpLevel(JELogLevelAlert, ##nonArrayExpression)

#define JEDumpLevel(level, nonArrayExpression...) \
    do \
    { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wunused-value\"") \
        /* We need to assign the expression to a variable in case it is an rvalue. */ \
        /* Since arrays cannot be assigned to another array, we use the comma operator in typeof(0, nonArrayExpression) to demote array types to their pointer counterparts. */ \
        const typeof(0, nonArrayExpression) _je_value = (nonArrayExpression); \
        _Pragma("clang diagnostic pop") \
        [JEDebugging \
         dumpLevel:level \
         location:JELogLocationCurrent() \
         label:(@""#nonArrayExpression) \
         value:[[NSValue alloc] \
                initWithBytes:({ \
                    /* We need to get the proper address to pass to NSValue. That is, if an array we need to pass itself, otherwise its address. Hopefully, this all gets optimized out by the compiler. */ \
                    const void *const _je_pointer = &_je_value; \
                    (@encode(typeof(nonArrayExpression))[0] == '[' \
                        ? *(const void *const *)_je_pointer \
                        : _je_pointer); \
                }) \
                objCType:@encode(typeof(nonArrayExpression))]]; \
    } while(0)


#pragma mark - JELog() variants

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JELog(formatString, ...) \
    JELogLevel(JE_LOG_DEFAULT_LEVEL, formatString, ##__VA_ARGS__)

#define JELogTrace(formatString, ...) \
    JELogLevel(JELogLevelTrace, formatString, ##__VA_ARGS__)

#define JELogNotice(formatString, ...) \
    JELogLevel(JELogLevelNotice, formatString, ##__VA_ARGS__)

#define JELogAlert(formatString, ...) \
    JELogLevel(JELogLevelAlert, formatString, ##__VA_ARGS__)

#define JELogLevel(level, formatString, ...) \
    [JEDebugging \
     logLevel:level \
     location:JELogLocationCurrent() \
     format:formatString, \
     ##__VA_ARGS__]


#pragma mark - JEDebugging class

@interface JEDebugging : NSObject

#pragma mark - logging

+ (void)dumpLevel:(JELogLevelMask)level
         location:(JELogLocation)location
            label:(NSString *)label
            value:(NSValue *)wrappedValue;

+ (void)logLevel:(JELogLevelMask)level
        location:(JELogLocation)location
          format:(NSString *)format, ... JE_FORMAT_STRING(3, 4);


#pragma mark - logger settings

+ (JEConsoleLoggerSettings *)copyConsoleLoggerSettings JE_WARN_UNUSED_RESULT;
+ (void)setConsoleLoggerSettings:(JEConsoleLoggerSettings *)consoleLoggerSettings;

+ (JEHUDLoggerSettings *)copyHUDLoggerSettings JE_WARN_UNUSED_RESULT;
+ (void)setHUDLoggerSettings:(JEHUDLoggerSettings *)HUDLoggerSettings;

+ (JEFileLoggerSettings *)copyFileLoggerSettings JE_WARN_UNUSED_RESULT;
+ (void)setFileLoggerSettings:(JEFileLoggerSettings *)fileLoggerSettings;


@end
