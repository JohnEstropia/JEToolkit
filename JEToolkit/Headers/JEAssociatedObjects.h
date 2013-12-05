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


#define JESynthesize(policy, type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        if (@encode(type)[0] == '@') \
        { \
            id _JEOwnershipAttribute_##policy _je_object = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
            const void *_je_objectPointer = &_je_object; \
            /* We will never reach here if the type is not an id, so we just ignore warnings. */ \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
            return *(typeof(type) _JEOwnershipAttribute_##policy *)_je_objectPointer; \
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

#define _JEOwnershipAttribute_assign            __unsafe_unretained
#define _JEOwnershipAttribute_unsafe_unretained __unsafe_unretained
#define _JEOwnershipAttribute_retain            __strong
#define _JEOwnershipAttribute_strong            __strong
#define _JEOwnershipAttribute_copy              __strong



#endif
