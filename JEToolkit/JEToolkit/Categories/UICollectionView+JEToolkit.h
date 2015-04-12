//
//  UICollectionView+JEToolkit.h
//  JEToolkit
//
//  Copyright (c) 2014 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (JEToolkit)

/*! Registers a UICollectionViewCell to the receiver for dequeueing. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
 @param collectionViewCellClass the UICollectionViewCell class name
 */
- (void)registerCollectionViewCellClass:(nonnull Class)collectionViewCellClass;

/*! Registers a UICollectionViewCell to the receiver for dequeueing. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
 @param collectionViewCellClass the UICollectionViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionViewCell class name.
 */
- (void)registerCollectionViewCellClass:(nonnull Class)collectionViewCellClass
                          subIdentifier:(nullable NSString *)subIdentifier;

/*! Registers a UICollectionReusableView to the receiver for dequeueing. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
 @param supplementaryViewClass the UICollectionReusableView class name
 @param supplementaryViewKind the UICollectionReusableView kind string
 */
- (void)registerSupplementaryViewClass:(nonnull Class)supplementaryViewClass
                                ofKind:(nonnull NSString *)supplementaryViewKind;

/*! Registers a UICollectionReusableView to the receiver for dequeueing. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
 @param supplementaryViewClass the UICollectionReusableView class name
 @param supplementaryViewKind the UICollectionReusableView kind string
 @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionReusableView class name.
 */
- (void)registerSupplementaryViewClass:(nonnull Class)supplementaryViewClass
                                ofKind:(nonnull NSString *)supplementaryViewKind
                         subIdentifier:(nullable NSString *)subIdentifier;

/*! Dequeues a UICollectionViewCell from the receiver. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
 @param collectionViewCellClass the UICollectionViewCell class name
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)collectionViewCellClass
                              forIndexPath:(nonnull NSIndexPath *)indexPath;

/*! Dequeues a UICollectionViewCell from the receiver. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
 @param collectionViewCellClass the UICollectionViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionViewCell class name.
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)collectionViewCellClass
                             subIdentifier:(nullable NSString *)subIdentifier
                              forIndexPath:(nonnull NSIndexPath *)indexPath;

/*! Dequeues a UICollectionReusableView from the receiver. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
 @param supplementaryViewClass the UICollectionReusableView class name
 @param supplementaryViewKind the UICollectionReusableView kind string
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueSupplementaryViewWithClass:(null_unspecified Class)supplementaryViewClass
                                         ofKind:(nonnull NSString *)supplementaryViewKind
                                   forIndexPath:(nonnull NSIndexPath *)indexPath;

/*! Dequeues a UICollectionReusableView from the receiver. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
 @param supplementaryViewClass the UICollectionReusableView class name
 @param supplementaryViewKind the UICollectionReusableView kind string
 @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionReusableView class name.
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueSupplementaryViewWithClass:(null_unspecified Class)supplementaryViewClass
                                         ofKind:(nonnull NSString *)supplementaryViewKind
                                  subIdentifier:(nullable NSString *)subIdentifier
                                   forIndexPath:(nonnull NSIndexPath *)indexPath;
@end
