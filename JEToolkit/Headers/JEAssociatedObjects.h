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


//#define JESynthesize(policy, type, getter, setter) \
//    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
//    \
//    - (type)getter \
//    { \
//        return _JESynthesize_get_##policy(type, getter); \
//    } \
//    \
//    - (void)setter:(type)getter \
//    { \
//        _JESynthesize_set_##policy(type, getter); \
//    }
//
//
//#define _JESynthesize_get_assign(type, getter) \
//    ({ \
//        /* We use an array so the initializer syntax will give us a nice zeroed-out value as default. */ \
//        typeof(type) _je_value[1] = {}; \
//        [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
//        _je_value[0]; \
//    })
//
//#define _JESynthesize_get_unsafe_unretained(type, getter) \
//    objc_getAssociatedObject(self, _JESynthesizeKey_##getter);
//
//#define _JESynthesize_get_strong    _JESynthesize_get_unsafe_unretained
//
//#define _JESynthesize_get_retain    _JESynthesize_get_unsafe_unretained
//
//#define _JESynthesize_get_copy      _JESynthesize_get_unsafe_unretained
//
//#define _JESynthesize_set_assign(type, getter) \
//    objc_setAssociatedObject(self, \
//                             _JESynthesizeKey_##getter, \
//                             [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
//                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//#define _JESynthesize_set_unsafe_unretained(type, getter) \
//    objc_setAssociatedObject(self, \
//                             _JESynthesizeKey_##getter, \
//                             getter, \
//                             OBJC_ASSOCIATION_ASSIGN);
//
//#define _JESynthesize_set_strong(type, getter) \
//    objc_setAssociatedObject(self, \
//                             _JESynthesizeKey_##getter, \
//                             getter, \
//                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//#define _JESynthesize_set_retain _JESynthesize_set_strong
//
//#define _JESynthesize_set_copy(type, getter) \
//    objc_setAssociatedObject(self, \
//                             _JESynthesizeKey_##getter, \
//                             getter, \
//                             OBJC_ASSOCIATION_COPY_NONATOMIC);


#define JESynthesize(policy, type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        /* If assign/unsafe_unretained semantics are set, then we treat the object as a value. This if/else (and actually all the pointer voodoo we're doing) will be optimized out by the compiler. */ \
        if (_JEAssociationPolicy_##policy != OBJC_ASSOCIATION_ASSIGN && @encode(type)[0] == '@') \
        { \
            id __strong _je_object = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
            const void *_je_objectPointer = &_je_object; \
            /* We will never reach here if the type is not an id, so we just ignore warnings. */ \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
            return *(typeof(type) __strong *)_je_objectPointer; \
            _Pragma("clang diagnostic pop") \
        } \
        else \
        { \
            /* We use an array so the initializer syntax will give us a nice zeroed-out value as default. */ \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic error \"-Wignored-attributes\"") \
            typeof(type) _JEAssociationAttribute_##policy _je_value[1] = {}; \
            _Pragma("clang diagnostic pop") \
            [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
            return _je_value[0]; \
        } \
    } \
    \
    - (void)setter:(type)getter \
    { \
        /* If assign/unsafe_unretained semantics are set, then we treat the object as a value. This if/else (and actually all the pointer voodoo we're doing) will be optimized out by the compiler. */ \
        if (_JEAssociationPolicy_##policy != OBJC_ASSOCIATION_ASSIGN && @encode(type)[0] == '@') \
        { \
            const void *_je_objectPointer = &getter; \
            objc_setAssociatedObject(self, \
                                     _JESynthesizeKey_##getter, \
                                     /* Method parameters are always retained, so we qualify with __strong. */ \
                                     *(id __strong *)_je_objectPointer, \
                                     _JEAssociationPolicy_##policy); \
        } \
        else \
        { \
            objc_setAssociatedObject(self, \
                                     _JESynthesizeKey_##getter, \
                                     [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        } \
    }


#define _JEAssociationPolicy_assign             OBJC_ASSOCIATION_ASSIGN
#define _JEAssociationPolicy_unsafe_unretained  OBJC_ASSOCIATION_ASSIGN
#define _JEAssociationPolicy_retain             OBJC_ASSOCIATION_RETAIN_NONATOMIC
#define _JEAssociationPolicy_strong             OBJC_ASSOCIATION_RETAIN_NONATOMIC
#define _JEAssociationPolicy_copy               OBJC_ASSOCIATION_COPY_NONATOMIC

#define _JEAssociationAttribute_assign
#define _JEAssociationAttribute_unsafe_unretained   __unsafe_unretained
#define _JEAssociationAttribute_retain              __strong
#define _JEAssociationAttribute_strong              __strong
#define _JEAssociationAttribute_copy                __strong



#endif
