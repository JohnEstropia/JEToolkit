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
    JELogLevelTrace     = 0,
    JELogLevelNotice    = (1 << 0),
    JELogLevelAlert     = (1 << 1),
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

/*! Dumps any variable, expression, etc. other than static arrays to the console.
 For static arrays use JEDumpArray() instead.
 */
#define JEDump(nonArrayExpression...) \
    do \
    { \
        const typeof(nonArrayExpression) _je_objectClone = nonArrayExpression; \
        [JEDebugging \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:&_je_objectClone \
                    objCType:@encode(typeof(nonArrayExpression))] \
         label:@""#nonArrayExpression \
         header:JE_LOG_HEADER]; \
    } while(0)

/*! Dumps static arrays to the console.
 For other variables, expressions, etc., use JEDump() instead.
 */
#define JEDumpArray(arrayExpression...) \
    do \
    { \
        [JEDebugging \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:&arrayExpression[0] \
                    objCType:@encode(typeof(arrayExpression))] \
         label:@""#arrayExpression \
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


#pragma mark - bullet settings

// default: ↪︎
+ (void)setDumpBulletString:(NSString *)dumpBulletString;
// default: 🔹
+ (void)setTraceBulletString:(NSString *)traceBulletString;
// default: 🔸
+ (void)setLogBulletString:(NSString *)logBulletString;
// default: ⚠️
+ (void)setAlertBulletString:(NSString *)alertBulletString;


#pragma mark - logging

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header;

+ (void)logLevel:(JELogLevelMask)level
          header:(JELogHeader)header
          format:(NSString *)format, ... JE_FORMAT_STRING(3, 4);

@end