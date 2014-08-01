//
//  UITableView+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/01.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (JEToolkit)

- (void)registerTableViewCellClass:(Class)tableViewCellClass;

- (void)registerTableViewCellClass:(Class)tableViewCellClass
                     subIdentifier:(NSString *)subIdentifier;

- (id)dequeueReusableCellWithClass:(Class)tableViewCellClass
                      forIndexPath:(NSIndexPath *)indexPath;

- (id)dequeueReusableCellWithClass:(Class)tableViewCellClass
                     subIdentifier:(NSString *)subIdentifier
                      forIndexPath:(NSIndexPath *)indexPath;

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass;

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass subIdentifier:(NSString *)subIdentifier;

@end
