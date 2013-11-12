//
//  JEDebugging.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


#if DEBUG

/*! Dumps any variable, expression, etc. other than static arrays to the console. Also displays the source filename, line number, and method name. For static arrays use je_dumpArray() instead.
 */
#define je_dump(...) \
    do \
    { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
        [JEDebugging \
         logValue:[NSValue \
                   valueWithBytes:(typeof(__VA_ARGS__)[]){(__VA_ARGS__)} \
                   objCType:@encode(typeof(__VA_ARGS__))] \
         sourceFile:__FILE__ \
         functionName:__PRETTY_FUNCTION__ \
         lineNumber:__LINE__ \
         label:#__VA_ARGS__]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Dumps static arrays to the console. Also displays the source filename, line number, and method name. For other variables, expressions, etc., use je_dump() instead.
 */
#define je_dumpArray(...) \
    do \
    { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
        _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
        [JEDebugging \
         logValue:[NSValue \
                   valueWithBytes:__VA_ARGS__ \
                   objCType:@encode(typeof(__VA_ARGS__))] \
         sourceFile:__FILE__ \
         functionName:__PRETTY_FUNCTION__ \
         lineNumber:__LINE__ \
         label:#__VA_ARGS__]; \
        _Pragma("clang diagnostic pop") \
    } while(0)

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define je_log(format, ...) \
    [JEDebugging \
     logFormat:format \
     sourceFile:__FILE__ \
     functionName:__PRETTY_FUNCTION__ \
     lineNumber:__LINE__, \
     __VA_ARGS__]

#else

#define je_dump(...)        do {} while(0)
#define je_dumpArray(...)   do {} while(0)
#define je_log(format, ...) do {} while(0)

#endif


@interface JEDebugging : NSObject

+ (void)logValue:(NSValue *)wrappedValue
      sourceFile:(const char *)sourceFile
    functionName:(const char *)functionName
      lineNumber:(NSInteger)lineNumber
           label:(const char *)label;

+ (void)logFormat:(NSString *)format
       sourceFile:(const char *)sourceFile
     functionName:(const char *)functionName
       lineNumber:(NSInteger)lineNumber, ... JE_FORMAT_STRING(1,5);

@end