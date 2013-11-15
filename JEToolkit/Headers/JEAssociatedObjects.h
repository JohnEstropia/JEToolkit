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

typedef NS_ENUM(NSInteger, JESynthesizePolicy)
{
    JESynthesizeAssign = OBJC_ASSOCIATION_ASSIGN,
    JESynthesizeRetainNonatomic = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    JESynthesizeCopyNonatomic = OBJC_ASSOCIATION_COPY_NONATOMIC,
    JESynthesizeRetain = OBJC_ASSOCIATION_RETAIN,
    JESynthesizeCopy = OBJC_ASSOCIATION_COPY
};


#define JESynthesizeObject(type, getter, setter, policy) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        return objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
    } \
    \
    - (void)setter:(type)getter \
    { \
        objc_setAssociatedObject(self, _JESynthesizeKey_##getter, getter, policy); \
    }


#define JESynthesizeScalar(type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    \
    - (type)getter \
    { \
        type scalarValue = {};\
        NSValue *value = objc_getAssociatedObject(self, _JESynthesizeKey_##getter); \
        [value getValue:&scalarValue]; \
        return scalarValue; \
    } \
    \
    - (void)setter:(type)getter \
    { \
        objc_setAssociatedObject(self, \
                                 _JESynthesizeKey_##getter, \
                                 [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }


#endif
