//
//  JRESafetyMacros.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JREToolkitDefines.h"


#ifndef JREToolkit_JRESafetyMacros_h
#define JREToolkit_JRESafetyMacros_h


#pragma mark - Safety macros

#if DEBUG

#define KVC(class, property)    ( ((class *)nil).property, @#property )

JRE_STATIC_INLINE JRE_NONNULL_ALL JRE_OVERLOAD
NSString *L8N(NSString *keyString)
{
	NSString *localizedString = NSLocalizedString(keyString, nil);
    NSCAssert(keyString != localizedString,
              @"\"%@\" not found in Localizable.strings",
              keyString);
    return localizedString;
}

JRE_STATIC_INLINE JRE_NONNULL_ALL JRE_OVERLOAD
NSString *L8N(NSString *keyString, NSString *stringsFile)
{
	NSString *localizedString = NSLocalizedStringFromTable(keyString, stringsFile, nil);
    NSCAssert(keyString != localizedString,
              @"\"%@\" not found in %@.strings",
              keyString,
              stringsFile);
    return localizedString;
}


#else

#define KVC(class, property)    ( @#property )

JRE_STATIC_INLINE JRE_NONNULL_ALL JRE_OVERLOAD
NSString *L8N(NSString *keyString)
{
    return NSLocalizedString(keyString, nil);
}

JRE_STATIC_INLINE JRE_NONNULL_ALL JRE_OVERLOAD
NSString *L8N(NSString *keyString, NSString *stringsFile)
{
    return NSLocalizedStringFromTable(keyString, stringsFile, nil);
}

#endif


#endif
