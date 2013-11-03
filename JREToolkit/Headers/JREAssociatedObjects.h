//
//  JREAssociatedObjects.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <objc/runtime.h>


#ifndef JREToolkit_JREAssociatedObjects_h
#define JREToolkit_JREAssociatedObjects_h


#define JRESynthesizeObject(type, getter, setter, policy) \
\
static const void *_JRESynthesizeKey_##getter = &_JRESynthesizeKey_##getter; \
\
- (type)getter { \
    return objc_getAssociatedObject(self, _JRESynthesizeKey_##getter); \
} \
\
- (void)setter:(type)getter { \
    objc_setAssociatedObject(self, _JRESynthesizeKey_##getter, getter, policy); \
}


#define JRESynthesizeAssignedObject(type, getter, setter)   JRESynthesizeObject(type, getter, setter, OBJC_ASSOCIATION_ASSIGN)


#define JRESynthesizeRetainedObject(type, getter, setter)   JRESynthesizeObject(type, getter, setter, OBJC_ASSOCIATION_RETAIN)


#define JRESynthesizeCopiedObject(type, getter, setter)   JRESynthesizeObject(type, getter, setter, OBJC_ASSOCIATION_COPY)


#define JRESynthesizeRetainedNonatomicObject(type, getter, setter)   JRESynthesizeObject(type, getter, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC)


#define JRESynthesizeCopiedNonatomicObject(type, getter, setter)   JRESynthesizeObject(type, getter, setter, OBJC_ASSOCIATION_COPY_NONATOMIC)


#define JRESynthesizeScalar(type, getter, setter) \
\
static const void *_JRESynthesizeKey_##getter = &_JRESynthesizeKey_##getter; \
\
- (type)getter { \
    typeof(type) scalarValue = {0};\
    NSValue *value = objc_getAssociatedObject(self, _JRESynthesizeKey_##getter); \
    [value getValue:&scalarValue]; \
    return scalarValue; \
} \
\
- (void)setter:(type)getter { \
    objc_setAssociatedObject(self, \
        _JRESynthesizeKey_##getter, \
        [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
        OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}


#endif
