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

- (void)registerTableViewCellClass:(nonnull Class)tableViewCellClass;
- (void)registerTableViewCellClass:(nonnull Class)tableViewCellClass
                     subIdentifier:(nullable NSString *)subIdentifier;

- (void)registerTableViewHeaderFooterViewClass:(nonnull Class)headerFooterViewClass;
- (void)registerTableViewHeaderFooterViewClass:(nonnull Class)headerFooterViewClass
                                 subIdentifier:(nullable NSString *)subIdentifier;

- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)tableViewCellClass
                      forIndexPath:(nullable NSIndexPath *)indexPath;
- (nonnull id)dequeueReusableCellWithClass:(null_unspecified Class)tableViewCellClass
                     subIdentifier:(nullable NSString *)subIdentifier
                      forIndexPath:(nullable NSIndexPath *)indexPath;

- (nonnull id)dequeueReusableHeaderFooterViewWithClass:(null_unspecified Class)headerFooterViewClass;
- (nonnull id)dequeueReusableHeaderFooterViewWithClass:(null_unspecified Class)headerFooterViewClass
                                 subIdentifier:(nullable NSString *)subIdentifier;

- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass;
- (nonnull id)cellForQueryingHeightWithClass:(null_unspecified Class)tableViewCellClass
                               subIdentifier:(nullable NSString *)subIdentifier;

@end
