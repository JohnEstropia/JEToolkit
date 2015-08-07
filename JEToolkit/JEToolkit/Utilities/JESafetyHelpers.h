//
//  JESafetyHelpers.h
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

#ifndef JEToolkit_JESafetyHelpers_h
#define JEToolkit_JESafetyHelpers_h

#import "JECompilerDefines.h"


#pragma mark - Key-Value Coding

#if DEBUG

#define JEKeypath(type, property) ({ \
        type _je_keypath_dummy __attribute__((unused)); \
        typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
        @#property; \
    })

#define JEKeypathOperator(operator, type, property) ({ \
        type _je_keypath_dummy __attribute__((unused)); \
        typeof(_je_keypath_dummy.property) _je_keypath_dummy_property __attribute__((unused)); \
        @"@" #operator "." #property; \
    })

#else

#define JEKeypath(type, property) \
    ( @#property )

#define JEKeypathOperator(operator, type, property) \
    ( @"@" #operator "." #property )

#endif



#pragma mark - Localizable Strings

JE_EXTERN
NSString *_Nonnull JEL10n(NSString *_Nonnull keyString);

JE_EXTERN
NSString *_Nonnull JEL10nFromFile(NSString *_Nonnull stringsFile, NSString *_Nonnull keyString);



#pragma mark - Convenience

#define JEEnumBitmasked(enumVar, enumBit) ( (enumVar & enumBit) == enumBit )



#pragma mark - ARC

#define JEScopeWeak(object) \
    typeof(object) __weak __je_scopeweak_##object = object

#define JEScopeStrong(object) \
    JE_PRAGMA_PUSH \
    JE_PRAGMA_IGNORE("-Wshadow") \
    typeof(object) __strong object = __je_scopeweak_##object \
    JE_PRAGMA_POP



#pragma mark - Blocks

#define JEBlockCreate(returnType, identifier, arguments, block...) \
    returnType (^identifier)arguments = ({ \
        typeof(identifier) __weak __block __je_block_weak_##identifier; \
        typeof(identifier) __je_block_strong_##identifier; \
        __je_block_weak_##identifier = __je_block_strong_##identifier = [^returnType(arguments){ \
            JE_PRAGMA_PUSH \
            JE_PRAGMA_IGNORE("-Wunused-variable") \
            returnType (^identifier)arguments = __je_block_weak_##identifier; \
            JE_PRAGMA_POP \
            { block } \
        } copy]; \
        __je_block_strong_##identifier; \
    })




#endif
