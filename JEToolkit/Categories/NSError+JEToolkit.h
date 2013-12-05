//
//  NSError+JEToolkit.h
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/12/05.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (JEToolkit)

/*! Returns an NSError from @p errno.
 */
+ (instancetype)lastPOSIXErrorWithUserInfo:(NSDictionary *)userInfo;

@end
