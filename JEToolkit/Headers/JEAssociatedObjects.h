//
//  JEAssociatedObjects.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <objc/runtime.h>


#ifndef JEToolkit_JEAssociatedObjects_h
#define JEToolkit_JEAssociatedObjects_h

#warning TODO: move all private definitions to separate header files

typedef enum
{
    _JESynthesizePolicy_assign = OBJC_ASSOCIATION_ASSIGN,
    _JESynthesizePolicy_unsafe_unretained = OBJC_ASSOCIATION_ASSIGN,
    _JESynthesizePolicy_retain = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    _JESynthesizePolicy_strong = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    _JESynthesizePolicy_copy = OBJC_ASSOCIATION_COPY_NONATOMIC,
} _JESynthesizePolicy;

#define _JEVarOwnership_assign              __unsafe_unretained
#define _JEVarOwnership_unsafe_unretained   __unsafe_unretained
#define _JEVarOwnership_retain              __strong
#define _JEVarOwnership_strong              __strong
#define _JEVarOwnership_copy                __strong

#define JESynthesize(type, getter, setter, policy) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        if (@encode(type)[0] == '@') \
        { \
            id _JEVarOwnership_##policy _je_object = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
            const void *_je_objectPointer = &_je_object; \
            /* We will never reach here if the type is not an id, so we just ignore warnings. */ \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
            return *(typeof(type) _JEVarOwnership_##policy *)_je_objectPointer; \
            _Pragma("clang diagnostic pop") \
        } \
        /* We use an array so the initializer syntax will give us a nice zeroed-out value as default. */ \
        typeof(type) _je_value[1] = {}; \
        [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
        return _je_value[0]; \
    } \
    \
    - (void)setter:(type)getter \
    { \
        if (@encode(type)[0] == '@') \
        { \
            const void *_je_objectPointer = &getter; \
            objc_setAssociatedObject(self, \
                                     _JESynthesizeKey_##getter, \
                                     /* Method parameters are always retained, so we qualify with __strong. */ \
                                     *(id __strong *)_je_objectPointer, \
                                     _JESynthesizePolicy_##policy); \
        } \
        else \
        { \
            objc_setAssociatedObject(self, \
                                     _JESynthesizeKey_##getter, \
                                     [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        } \
    }


#define JESynthesizeObjCType(objCType, getter, setter, policy) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (objCType)getter \
    { \
        return objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
    } \
    \
    - (void)setter:(objCType)getter \
    { \
        objc_setAssociatedObject(self, _JESynthesizeKey_##getter, getter, _JESynthesizePolicy_##policy); \
    }


#define JESynthesizeValueType(valueType, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (valueType)getter \
    { \
        /* We make this an array so we can use the initializer syntax for a nice zeroed-out value */ \
        valueType scalarValue[1] = {}; \
        NSValue *value = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
        [value getValue:scalarValue]; \
        return scalarValue[0]; \
    } \
    \
    - (void)setter:(valueType)getter \
    { \
        objc_setAssociatedObject(self, \
                                 _JESynthesizeKey_##getter, \
                                 [[NSValue alloc] initWithBytes:&getter objCType:@encode(valueType)], \
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }


#endif
