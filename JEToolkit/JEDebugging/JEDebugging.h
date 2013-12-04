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


#pragma mark - Log message header masks

typedef NS_OPTIONS(NSUInteger, JEConsoleLogHeaderMask)
{
    JEConsoleLogHeaderNone      = 0,
    JEConsoleLogHeaderDate      = (1 << 0),
    JEConsoleLogHeaderQueue     = (1 << 1),
    
    // Note that JEConsoleLogHeaderFile and JEConsoleLogHeaderFunction are ignored if neither DEBUG or JE_COMPILE_WITH_LOG_HEADER_CONSTANTS are defined. This is to prevent project directories and private method names from appearing in the app binary.
    JEConsoleLogHeaderFile      = (1 << 2),
    JEConsoleLogHeaderFunction  = (1 << 3),
    
    JEConsoleLogHeaderAll       = ~0u
};


#pragma mark - Log message levels

typedef NS_OPTIONS(NSUInteger, JELogLevelMask)
{
    JELogLevelNone      = 0,
    JELogLevelTrace     = (1 << 0),
    JELogLevelNotice    = (1 << 1),
    JELogLevelAlert     = (1 << 2),
    // add custom masks here
    
    JELogLevelAll       = ~0u
};

#ifndef JE_LOG_DEFAULT_LEVEL
#define JE_LOG_DEFAULT_LEVEL JELogLevelTrace
#endif

#ifndef JE_DUMP_DEFAULT_LEVEL
#define JE_DUMP_DEFAULT_LEVEL JELogLevelTrace
#endif


#pragma mark - Log message header constants container

typedef struct JELogHeader
{
    const char *fileName;
    const char *functionName;
    int lineNumber;
} JELogHeader;

#if defined(DEBUG) || JE_COMPILE_WITH_LOG_HEADER_CONSTANTS
#define JE_LOG_HEADER  ((JELogHeader){ JE_FILE_NAME, __PRETTY_FUNCTION__, __LINE__ })
#else
#define JE_LOG_HEADER  ((JELogHeader){ NULL, NULL, 0 })
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
        [JEDebugging \
         dumpLevel:level \
         header:JE_LOG_HEADER \
         label:(@""#nonArrayExpression) \
         value:[[NSValue alloc] \
                initWithBytes:({ \
                    /* We need to get the proper address to pass to NSValue. That is, if an array we need to pass itself, otherwise its address. Hopefully, this all gets optimized out by the compiler. */ \
                    const void *_je_pointer = &_je_value; \
                    (@encode(typeof(nonArrayExpression))[0] == '[' \
                        ?  *(const void **)_je_pointer \
                        : (const void *)_je_pointer); \
                }) \
                objCType:@encode(typeof(nonArrayExpression))]]; \
        _Pragma("clang diagnostic pop") \
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
     header:JE_LOG_HEADER \
     format:formatString, \
     ##__VA_ARGS__]


#pragma mark - JEDebugging class

@interface JEDebugging : NSObject

#pragma mark - logging

+ (void)dumpLevel:(JELogLevelMask)level
           header:(JELogHeader)header
            label:(NSString *)label
            value:(NSValue *)wrappedValue;

+ (void)logLevel:(JELogLevelMask)level
          header:(JELogHeader)header
          format:(NSString *)format, ... JE_FORMAT_STRING(3, 4);


#pragma mark - HUD settings

// default: NO
+ (void)setIsHUDEnabled:(BOOL)isHUDEnabled;


#pragma mark - log header mask settings

// default: (JEConsoleLogHeaderQueue | JEConsoleLogHeaderFile | JEConsoleLogHeaderFunction)
+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask;
// default: (JEConsoleLogHeaderQueue | JEConsoleLogHeaderFile | JEConsoleLogHeaderFunction)
+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask;
// default: JEConsoleLogHeaderAll
+ (void)setFileLogHeaderMask:(JEConsoleLogHeaderMask)mask;


#pragma mark - log destination mask settings

// default: JELogLevelAll
+ (void)setConsoleLogLevelMask:(JELogLevelMask)mask;
// default: JELogLevelAll
+ (void)setHUDLogLevelMask:(JELogLevelMask)mask;
// default: (JELogLevelNotice | JELogLevelAlert)
+ (void)setFileLogLevelMask:(JELogLevelMask)mask;

#warning TODO: move all settings to corresponding settings classes


@end
