//
//  JEAssociatedObject.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/03/21.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "JECompilerDefines.h"


#if !__has_feature(objc_arc)
#error JESynthesize() requires ARC be enabled
#endif


#ifdef DEBUG

#define JESynthesize(ownership, type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        /* If assign/unsafe_unretained semantics are set, then we treat the object as a value. This if/else (and actually all the pointer voodoo we're doing) will be optimized out by the compiler. */ \
        if (@encode(type)[0] == '@')\
        { \
            if (_JEAssociationCompilerFlag_##ownership == _JEAssociationCompilerFlag_weak) \
            { \
                id __attribute__((objc_precise_lifetime)) __strong _je_object = [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) weakObjectValue]; \
                const void *_je_objectPointer = &_je_object; \
                /* We will never reach here if the type is not an id, so we just ignore warnings. */ \
                JE_PRAGMA_PUSH \
                JE_PRAGMA_IGNORE("-Wignored-attributes") \
                return *(typeof(type) __strong *)_je_objectPointer; \
                JE_PRAGMA_POP \
            } \
            else \
            { \
                id __attribute__((objc_precise_lifetime)) __strong _je_object = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
                const void *_je_objectPointer = &_je_object; \
                /* We will never reach here if the type is not an id, so we just ignore warnings. */ \
                JE_PRAGMA_PUSH \
                JE_PRAGMA_IGNORE("-Wignored-attributes") \
                return *(typeof(type) __strong *)_je_objectPointer; \
                JE_PRAGMA_POP \
            } \
        } \
        else \
        { \
            /* We use an array so the initializer syntax will give us a nice zeroed-out value as default. */ \
            JE_PRAGMA_PUSH \
            JE_PRAGMA_ERROR("-Wignored-attributes") \
            typeof(type) _JEAssociationAttribute_##ownership _je_value[1] = {}; \
            JE_PRAGMA_POP \
            JE_PRAGMA_PUSH \
            JE_PRAGMA_IGNORE("-Warc-repeated-use-of-weak") \
            [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
            JE_PRAGMA_POP \
            return _je_value[0]; \
        } \
    } \
    \
    - (void)setter:(type)getter \
    { \
        /* If assign/unsafe_unretained semantics are set, then we treat the object as a value. This if/else (and actually all the pointer voodoo we're doing) will be optimized out by the compiler. */ \
        if (@encode(type)[0] == '@') \
        { \
            if (_JEAssociationCompilerFlag_##ownership == _JEAssociationCompilerFlag_weak) \
            { \
                const void *_je_objectPointer = &getter; \
                objc_setAssociatedObject(self, \
                                         _JESynthesizeKey_##getter, \
                                         [NSValue valueWithWeakObject:*(id __strong *)_je_objectPointer], \
                                         OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
            } \
            else \
            { \
                const void *_je_objectPointer = &getter; \
                objc_setAssociatedObject(self, \
                                         _JESynthesizeKey_##getter, \
                                         /* Method parameters are always retained, so we qualify with __strong. */ \
                                         *(id __strong *)_je_objectPointer, \
                                         _JEAssociationOwnership_##ownership); \
            } \
        } \
        else \
        { \
            objc_setAssociatedObject(self, \
                                     _JESynthesizeKey_##getter, \
                                     [NSValue valueWithBytes:&getter objCType:@encode(type)], \
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        } \
    }

#define _JEAssociationCompilerFlag_assign               0
#define _JEAssociationCompilerFlag_unsafe_unretained    1
#define _JEAssociationCompilerFlag_retain               2
#define _JEAssociationCompilerFlag_strong               3
#define _JEAssociationCompilerFlag_copy                 4
#define _JEAssociationCompilerFlag_weak                 5

#define _JEAssociationOwnership_assign              OBJC_ASSOCIATION_ASSIGN
#define _JEAssociationOwnership_unsafe_unretained   OBJC_ASSOCIATION_ASSIGN
#define _JEAssociationOwnership_retain              OBJC_ASSOCIATION_RETAIN_NONATOMIC
#define _JEAssociationOwnership_strong              OBJC_ASSOCIATION_RETAIN_NONATOMIC
#define _JEAssociationOwnership_copy                OBJC_ASSOCIATION_COPY_NONATOMIC
#define _JEAssociationOwnership_weak                OBJC_ASSOCIATION_ASSIGN

#define _JEAssociationAttribute_assign
#define _JEAssociationAttribute_unsafe_unretained   __unsafe_unretained
#define _JEAssociationAttribute_retain              __strong
#define _JEAssociationAttribute_strong              __strong
#define _JEAssociationAttribute_copy                __strong
#define _JEAssociationAttribute_weak                __weak


#else

#define JESynthesize(ownership, type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        return _JESynthesize_get_##ownership(type, getter); \
    } \
    \
    - (void)setter:(type)getter \
    { \
        _JESynthesize_set_##ownership(type, getter); \
    }


#define _JESynthesize_get_assign(type, getter) \
    ({ \
        /* We use an array so the initializer syntax will give us a nice zeroed-out value as default. */ \
        typeof(type) _je_value[1] = {}; \
        [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
        _je_value[0]; \
    })

#define _JESynthesize_get_unsafe_unretained(type, getter) \
    objc_getAssociatedObject(self, _JESynthesizeKey_##getter);

#define _JESynthesize_get_strong    _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_retain    _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_copy      _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_weak(type, getter) \
    [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter)) weakObjectValue]

#define _JESynthesize_set_assign(type, getter) \
    objc_setAssociatedObject(self, \
                             _JESynthesizeKey_##getter, \
                             [NSValue valueWithBytes:&getter objCType:@encode(type)], \
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

#define _JESynthesize_set_unsafe_unretained(type, getter) \
    objc_setAssociatedObject(self, \
                             _JESynthesizeKey_##getter, \
                             getter, \
                             OBJC_ASSOCIATION_ASSIGN);

#define _JESynthesize_set_strong(type, getter) \
    objc_setAssociatedObject(self, \
                             _JESynthesizeKey_##getter, \
                             getter, \
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

#define _JESynthesize_set_retain _JESynthesize_set_strong

#define _JESynthesize_set_copy(type, getter) \
    objc_setAssociatedObject(self, \
                             _JESynthesizeKey_##getter, \
                             getter, \
                             OBJC_ASSOCIATION_COPY_NONATOMIC);

#define _JESynthesize_set_weak(type, getter) \
    objc_setAssociatedObject(self, \
                             _JESynthesizeKey_##getter, \
                             [NSValue valueWithWeakObject:getter], \
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);


#endif


@interface NSValue (JEAssociatedObject)

+ (NSValue *)valueWithWeakObject:(id)weakObject;
- (id)weakObjectValue;

@end
