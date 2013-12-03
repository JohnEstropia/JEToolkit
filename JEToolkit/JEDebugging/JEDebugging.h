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

typedef NS_OPTIONS(NSUInteger, JELogLevelMask)
{
    JELogLevelNone      = 0,
    JELogLevelTrace     = (1 << 0),
    JELogLevelNotice    = (1 << 1),
    JELogLevelAlert     = (1 << 2),
    // add custom masks here
    
    JELogLevelAll       = ~0u
};


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

/*! Dumps detailed information of any variable or expression to the console.
 Note that a bug(?) with NSGetSizeAndAlignment() and NSValue prevents structs and unions with bitfields to be wrapped in NSValue, in which case JEDump() will just print "(struct ?){ ... }".
 The macro argument is variadic to allow expressions that have commas in them. You can use this as a trick to use the comma operator to attach a string before the expression such as JEDump("This will be 2", 1+1); Be warned though that you cannot use the same trick for arrays as the typeof() evaluation will be different:
 @encode(typeof(arrayVariable)) == "[7i]"
 @encode(typeof("dont", arrayVariable)) == "^i"
 In the second case, only the first item in the array will be printed (or crash if you passed an empty array).
 */
#define JEDump(nonArrayExpression...) \
    do \
    { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wunused-value\"") \
        /* We need to assign the expression to a variable in case it is not an lvalue. The comma operator in typeof(0, nonArrayExpression) is needed to demote array types into pointers. */ \
        const typeof(0, nonArrayExpression) _je_expressionValue = (nonArrayExpression); \
        /* We use _JE_PtrForType() to get the proper address to pass to NSValue. That is, for arrays we need to pass _je_expressionValue directly, otherwise we pass the address of _je_expressionValue. */ \
        [JEDebugging \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:_JE_PtrForType(&_je_expressionValue, @encode(typeof(nonArrayExpression))) \
                    objCType:@encode(typeof(nonArrayExpression))] \
         label:(@""#nonArrayExpression) \
         header:JE_LOG_HEADER]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Dumps static arrays to the console.
 For other variables, expressions, etc., use JEDump() instead.
 */
#define JEDumpArray(arrayExpression...) \
    do \
    { \
        [JEDebugging \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:&(arrayExpression[0]) \
                    objCType:@encode(typeof((arrayExpression)))] \
         label:(@""#arrayExpression) \
         header:JE_LOG_HEADER]; \
    } while(0)

#ifndef JE_LOG_DEFAULT_LEVEL
#define JE_LOG_DEFAULT_LEVEL JELogLevelTrace
#endif

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


@interface JEDebugging : NSObject

#pragma mark - logging

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header;

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


@end


#pragma mark - Internal

JE_STATIC_INLINE const void *_JE_PtrForType(const void *objPtr, const char objCType[])
{
    return (objCType[0] == '[' ?  *(const void **)objPtr : objPtr);
}