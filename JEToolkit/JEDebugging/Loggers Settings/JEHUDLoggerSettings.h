//
//  JEHUDLoggerSettings.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEBaseLoggerSettings.h"

@interface JEHUDLoggerSettings : JEBaseLoggerSettings

@property (nonatomic, assign) BOOL visibleOnStart;
@property (nonatomic, assign) NSUInteger numberOfLogEntriesInMemory;

@end
