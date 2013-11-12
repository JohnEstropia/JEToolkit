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


#define je_synthesizeObject(type, getter, setter, policy) \
    static const void *_je_synthesizeKey_##getter = &_je_synthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        return objc_getAssociatedObject(self, _je_synthesizeKey_##getter); \
    } \
    \
    - (void)setter:(type)getter \
    { \
        objc_setAssociatedObject(self, _je_synthesizeKey_##getter, getter, policy); \
    }


#define je_synthesizeAssignedObject(type, getter, setter) \
    je_synthesizeObject(type, getter, setter, OBJC_ASSOCIATION_ASSIGN)


#define je_synthesizeRetainedObject(type, getter, setter) \
    je_synthesizeObject(type, getter, setter, OBJC_ASSOCIATION_RETAIN)


#define je_synthesizeCopiedObject(type, getter, setter) \
    je_synthesizeObject(type, getter, setter, OBJC_ASSOCIATION_COPY)


#define je_synthesizeRetainedNonatomicObject(type, getter, setter) \
    je_synthesizeObject(type, getter, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC)


#define je_synthesizeCopiedNonatomicObject(type, getter, setter) \
    je_synthesizeObject(type, getter, setter, OBJC_ASSOCIATION_COPY_NONATOMIC)


#define je_synthesizeScalar(type, getter, setter) \
    static const void *_je_synthesizeKey_##getter = &_je_synthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        typeof(type) scalarValue = {0};\
        NSValue *value = objc_getAssociatedObject(self, _je_synthesizeKey_##getter); \
        [value getValue:&scalarValue]; \
        return scalarValue; \
    } \
    \
    - (void)setter:(type)getter \
    { \
        objc_setAssociatedObject(self, \
                                 _je_synthesizeKey_##getter, \
                                 [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }


#endif
