//
//  UICollectionView+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/01.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (JEToolkit)

- (void)registerCollectionViewCellClass:(Class)collectionViewCellClass;

- (void)registerCollectionViewCellClass:(Class)collectionViewCellClass
                          subIdentifier:(NSString *)subIdentifier;

- (id)dequeueReusableCellWithClass:(Class)collectionViewCellClass
                      forIndexPath:(NSIndexPath *)indexPath;

- (id)dequeueReusableCellWithClass:(Class)collectionViewCellClass
                     subIdentifier:(NSString *)subIdentifier
                      forIndexPath:(NSIndexPath *)indexPath;

@end
