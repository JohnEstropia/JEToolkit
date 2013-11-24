//
//  JEDebugging.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


typedef struct {
    const char *sourceFile;
    const char *functionName;
    int lineNumber;
} JELogHeader;

#define JE_LOG_HEADER  ((JELogHeader){__FILE__, __PRETTY_FUNCTION__, __LINE__})


#if DEBUG

/*! Dumps any variable, expression, etc. other than static arrays to the console. Also displays the source filename, line number, and method name. For static arrays use JEDumpArray() instead.
 */
#define JEDump(nonArrayExpression...) \
    do \
    { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
        const typeof(nonArrayExpression) _objectClone = nonArrayExpression; \
        [JEDebugging \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:&_objectClone \
                    objCType:@encode(typeof(nonArrayExpression))] \
         label:#nonArrayExpression \
         header:JE_LOG_HEADER]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Dumps static arrays to the console. Also displays the source filename, line number, and method name. For other variables, expressions, etc., use JEDump() instead.
 */
#define JEDumpArray(arrayExpression...) \
    do \
    { \
        [JEDebugging \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
         dumpValue:[[NSValue alloc] \
                    initWithBytes:&arrayExpression[0] \
                    objCType:@encode(typeof(arrayExpression))] \
         label:#arrayExpression \
         header:JE_LOG_HEADER]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JELog(format, ...) \
    [JEDebugging \
      logFormat:format \
      header:JE_LOG_HEADER, \
      ##__VA_ARGS__]

#else

#define JEDump(...)        do {} while(0)
#define JEDumpArray(...)   do {} while(0)
#define JELog(format, ...) do {} while(0)

#endif


typedef NS_OPTIONS(NSUInteger, JEConsoleLogHeaderMask)
{
    JEConsoleLogHeaderMaskNone      = 0,
    JEConsoleLogHeaderMaskDate      = (1 << 1),
    JEConsoleLogHeaderMaskQueue     = (1 << 2),
    JEConsoleLogHeaderMaskFile      = (1 << 3),
    JEConsoleLogHeaderMaskFunction  = (1 << 4),
    
    JEConsoleLogHeaderMaskAll       = -1
};


@interface JEDebugging : NSObject

+ (JEConsoleLogHeaderMask)consoleLogHeaderMask; // default:(JEConsoleLogHeaderMaskQueue | JEConsoleLogHeaderMaskFile | JEConsoleLogHeaderMaskFunction)
+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask;

+ (JEConsoleLogHeaderMask)HUDLogHeaderMask; // default:(JEConsoleLogHeaderMaskQueue | JEConsoleLogHeaderMaskFile | JEConsoleLogHeaderMaskFunction)
+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask;

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(const char *)label
           header:(JELogHeader)header;

+ (void)logFormat:(NSString *)format
           header:(JELogHeader)header, ... JE_FORMAT_STRING(1,3);

@end