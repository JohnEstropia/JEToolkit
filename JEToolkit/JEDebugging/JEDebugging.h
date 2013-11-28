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


typedef struct JELogHeader {
    const char *fileName;
    const char *functionName;
    int lineNumber;
} JELogHeader;


typedef NS_OPTIONS(NSUInteger, JEConsoleLogHeaderMask)
{
    JEConsoleLogHeaderMaskNone      = 0,
    JEConsoleLogHeaderMaskDate      = (1 << 0),
    JEConsoleLogHeaderMaskQueue     = (1 << 1),
    JEConsoleLogHeaderMaskFile      = (1 << 2),
    JEConsoleLogHeaderMaskFunction  = (1 << 3),
    JEConsoleLogHeaderMaskDefault   = (JEConsoleLogHeaderMaskQueue
                                       | JEConsoleLogHeaderMaskFile
                                       | JEConsoleLogHeaderMaskFunction),
    JEConsoleLogHeaderMaskAll       = ~0u
};

typedef NS_OPTIONS(NSUInteger, JELogLevel)
{
    JELogLevelTrace     = 0,
    JELogLevelLog       = (1 << 0),
    JELogLevelAlert     = (1 << 1),
    // add custom masks here
    
    JELogLevelAll       = ~0u
};


#ifdef DEBUG

#define JE_FILE_NAME   ((strrchr(__FILE__, '/') ?: (__FILE__ - 1)) + 1)
#define JE_LOG_HEADER  ((JELogHeader){ JE_FILE_NAME, __PRETTY_FUNCTION__, __LINE__ })

#else

#define JE_FILE_NAME   NULL
#define JE_LOG_HEADER  ((JELogHeader){ JE_FILE_NAME, NULL, 0 })

#endif

/*! Dumps any variable, expression, etc. other than static arrays to the console. Also displays the source filename, line number, and method name. For static arrays use JEDumpArray() instead.
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

/*! Dumps static arrays to the console. Also displays the source filename, line number, and method name. For other variables, expressions, etc., use JEDump() instead.
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

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JELog(format, ...) \
    [JEDebugging \
      logFormat:format \
      header:JE_LOG_HEADER, \
      ##__VA_ARGS__]

#warning TODO: http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
#define JELog(expression...)


@interface JEDebugging : NSObject

#pragma mark - HUD settings

+ (BOOL)isHUDEnabled;
+ (void)setIsHUDEnabled:(BOOL)isHUDEnabled;

+ (JEConsoleLogHeaderMask)consoleLogHeaderMask;
+ (JEConsoleLogHeaderMask)HUDLogHeaderMask;
+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask;
+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask;


#pragma mark - bullet settings

+ (NSString *)dumpBulletString;
+ (NSString *)traceBulletString;
+ (NSString *)logBulletString;
+ (NSString *)alertBulletString;
+ (void)setDumpBulletString:(NSString *)dumpBulletString;
+ (void)setTraceBulletString:(NSString *)traceBulletString;
+ (void)setLogBulletString:(NSString *)logBulletString;
+ (void)setAlertBulletString:(NSString *)alertBulletString;


#pragma mark - logging

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header;

+ (void)logFormat:(NSString *)format
           header:(JELogHeader)header, ... JE_FORMAT_STRING(1,3);

@end