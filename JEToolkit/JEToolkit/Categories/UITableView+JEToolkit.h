//
//  UITableView+JEToolkit.h
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

@interface UITableView (JEToolkit)

/*! Registers a UITableViewCell to the receiver for dequeueing. Requires the UITableViewCell's nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 */
- (void)registerTableViewCellClass:(nonnull Class)tableViewCellClass;

/*! Registers a UITableViewCell to the receiver for dequeueing. Requires the UITableViewCell's nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
 */
- (void)registerTableViewCellClass:(nonnull Class)tableViewCellClass
                     subIdentifier:(nullable NSString *)subIdentifier;

/*! Registers a UITableViewHeaderFooterView to the receiver for dequeueing. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
 @param headerFooterViewClass the UITableViewHeaderFooterView class name
 */
- (void)registerTableViewHeaderFooterViewClass:(nonnull Class)headerFooterViewClass;

/*! Registers a UITableViewHeaderFooterView to the receiver for dequeueing. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
 @param headerFooterViewClass the UITableViewHeaderFooterView class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewHeaderFooterView class name.
 */
- (void)registerTableViewHeaderFooterViewClass:(nonnull Class)headerFooterViewClass
                                 subIdentifier:(nullable NSString *)subIdentifier;

/*! Dequeues a UITableViewCell from the receiver. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)tableViewCellClass
                              forIndexPath:(nullable NSIndexPath *)indexPath;

/*! Dequeues a UITableViewCell from the receiver. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
 @param indexPath the index path for the cell to dequeue
 */
- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)tableViewCellClass
                             subIdentifier:(nullable NSString *)subIdentifier
                              forIndexPath:(nullable NSIndexPath *)indexPath;

/*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
 @param headerFooterViewClass the UITableViewHeaderFooterView class name
 */
- (nonnull id)dequeueReusableHeaderFooterViewWithClass:(null_unspecified Class)headerFooterViewClass;

/*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
 @param headerFooterViewClass the UITableViewHeaderFooterView class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
 */
- (nonnull id)dequeueReusableHeaderFooterViewWithClass:(null_unspecified Class)headerFooterViewClass
                                         subIdentifier:(nullable NSString *)subIdentifier;

/*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 */
- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass;

/*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param setupBlock a block to perform before the cell calls -layoutIfNeeded
 */
- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass
                                  setupBlock:(nullable void (^)(id _Nonnull cell))setupBlock;

/*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
 */
- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass
                               subIdentifier:(nullable NSString *)subIdentifier;

/*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
 @param tableViewCellClass the UITableViewCell class name
 @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
 @param setupBlock a block to perform before the cell calls -layoutIfNeeded
 */
- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass
                               subIdentifier:(nullable NSString *)subIdentifier
                                  setupBlock:(nullable void (^)(id _Nonnull cell))setupBlock;

@end
