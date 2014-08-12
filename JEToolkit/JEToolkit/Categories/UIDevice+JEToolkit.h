//
//  UIDevice+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/12.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (JEToolkit)

@property (nonatomic, strong, readonly) NSString *platform;
@property (nonatomic, strong, readonly) NSString *hardwareName;

@end
