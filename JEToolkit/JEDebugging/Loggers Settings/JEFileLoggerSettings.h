//
//  JEFileLoggerSettings.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/04.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEBaseLoggerSettings.h"

@interface JEFileLoggerSettings : JEBaseLoggerSettings

@property (nonatomic, copy) NSURL *fileLogsDirectoryURL;
@property (nonatomic, assign) unsigned long long numberOfBytesInMemoryBeforeWritingToFile;
@property (nonatomic, assign) NSUInteger numberOfDaysBeforeDeletingFile;

@end
