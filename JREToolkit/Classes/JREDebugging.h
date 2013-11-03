//
//  JREDebugging.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JREToolkitDefines.h"


#if DEBUG

/*! Dumps any variable, expression, etc. other than static arrays to the console. Also displays the source filename, line number, and method name. For static arrays use JREDumpArray() instead.
 */
#define JREDump(...) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
        [JREDebugging logValue:[NSValue valueWithBytes:(typeof(__VA_ARGS__)[]){(__VA_ARGS__)} \
                                              objCType:@encode(typeof(__VA_ARGS__))] \
                    sourceFile:__FILE__ \
                  functionName:__PRETTY_FUNCTION__ \
                    lineNumber:__LINE__ \
                         label:#__VA_ARGS__]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Dumps static arrays to the console. Also displays the source filename, line number, and method name. For other variables, expressions, etc., use JREDump() instead.
 */
#define JREDumpArray(...) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
        [JREDebugging logValue:[NSValue valueWithBytes:__VA_ARGS__ \
                                              objCType:@encode(typeof(__VA_ARGS__))] \
                    sourceFile:__FILE__ \
                  functionName:__PRETTY_FUNCTION__ \
                    lineNumber:__LINE__ \
                         label:#__VA_ARGS__]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JRELog(format, ...) \
    _JRELogFormat(__FILE__, __LINE__, __PRETTY_FUNCTION__, format, __VA_ARGS__)


#else

#define JREDump(...)        do {} while(0)
#define JREDumpArray(...)   do {} while(0)
#define JRELog(format, ...) do {} while(0)

#endif


JRE_EXTERN
void _JRELogObject(const char *filePath,
                   int line,
                   const char *functionName,
                   const char *objectName,
                   const void *value,
                   const char *objCType);

JRE_EXTERN_INLINE JRE_FORMAT_STRING(4,5)
void _JRELogFormat(const char *filePath,
                   int line,
                   const char *functionName,
                   NSString *format,
                   ...);


@interface JREDebugging : NSObject

+ (void)logValue:(NSValue *)wrappedValue
      sourceFile:(const char *)sourceFile
    functionName:(const char *)functionName
      lineNumber:(NSInteger)lineNumber
           label:(const char *)label;

+ (void)logFormat:(NSString *)format
       sourceFile:(const char *)sourceFile
     functionName:(const char *)functionName
       lineNumber:(NSInteger)lineNumber, ... JRE_FORMAT_STRING(1,5);

@end