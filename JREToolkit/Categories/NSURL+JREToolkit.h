//
//  NSURL+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (JREToolkit)

/*! Returns the known UTI for the receiver
 */
- (NSString *)UTI;

/*! Returns the known mimetype for the receiver, or "application/octet-stream" if a known mimetype was not found
 */
- (NSString *)mimeType;

/*! Checks if the reciever is an assets library URL
 */
- (BOOL)isAssetsLibraryURL;

/*! Checks if the reciever is a data URL
 */
- (BOOL)isDataURL;

/*! Excludes or includes the resource pointed to by the receiver from iCloud or iTunes backup.
 @param excludeFromBackup YES to prevent the resource from being backed up, NO to include in backups
 @return YES if the setting change succeeded, NO otherwise
 */
- (BOOL)setExcludeFromBackup:(BOOL)excludeFromBackup;

@end
