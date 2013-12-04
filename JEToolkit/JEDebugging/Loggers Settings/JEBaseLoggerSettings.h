//
//  JEBaseLoggerSettings.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, JELogLevelMask)
{
    JELogLevelNone      = 0,
    JELogLevelTrace     = (1 << 0),
    JELogLevelNotice    = (1 << 1),
    JELogLevelAlert     = (1 << 2),
    // add custom masks here
    
    JELogLevelAll       = ~0u
};

typedef NS_OPTIONS(NSUInteger, JELogMessageHeaderMask)
{
    JELogMessageHeaderNone          = 0,
    JELogMessageHeaderDate          = (1 << 0),
    JELogMessageHeaderQueue         = (1 << 1),
    
    JELogMessageHeaderSourceFile    = (1 << 2), // includes line number
    JELogMessageHeaderFunction      = (1 << 3),
    
    JELogMessageHeaderAll           = ~0u
};


@interface JEBaseLoggerSettings : NSObject <NSCopying>

@property (nonatomic, assign) JELogLevelMask logLevelMask;
@property (nonatomic, assign) JELogMessageHeaderMask logMessageHeaderMask;

@end
