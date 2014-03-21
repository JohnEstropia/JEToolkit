//
//  JEHUDLogView.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JEHUDLoggerSettings.h"


@interface JEHUDLogView : UIView

- (instancetype)initWithFrame:(CGRect)frame
           threadSafeSettings:(JEHUDLoggerSettings *)HUDLogSettings;

- (void)addLogString:(NSString *)logString
withThreadSafeSettings:(JEHUDLoggerSettings *)HUDLogSettings;

@end
