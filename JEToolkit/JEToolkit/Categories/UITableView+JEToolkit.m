//
//  UITableView+JEToolkit.m
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

#import "UITableView+JEToolkit.h"
#import "NSObject+JEToolkit.h"
#import "UINib+JEToolkit.h"
#import "JESynthesize.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#define JEAssert            NSCAssert
#endif


@implementation UITableView (JEToolkit)

#pragma mark - Private

JESynthesize(strong, NSCache *, cellHeightQueryingCache, setCellHeightQueryingCache);
JESynthesize(strong, NSCache *, headerFooterViewHeightQueryingCache, setHeaderFooterViewHeightQueryingCache);


#pragma mark - Public

- (void)registerTableViewCellClass:(Class)tableViewCellClass {
    
    [self registerTableViewCellClass:tableViewCellClass subIdentifier:nil];
}

- (void)registerTableViewCellClass:(Class)tableViewCellClass
                     subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([tableViewCellClass isSubclassOfClass:[UITableViewCell class]]);
    
    NSString *className = [tableViewCellClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    if ([UINib nibWithNameExists:className]) {
        
        [self
         registerNib:[UINib cachedNibWithName:className]
         forCellReuseIdentifier:reuseIdentifier];
    }
    else {
        
        [self
         registerClass:tableViewCellClass
         forCellReuseIdentifier:reuseIdentifier];
    }
}

- (void)registerTableViewHeaderFooterViewClass:(Class)headerFooterViewClass {
    
    [self registerTableViewHeaderFooterViewClass:headerFooterViewClass subIdentifier:nil];
}

- (void)registerTableViewHeaderFooterViewClass:(Class)headerFooterViewClass
                                 subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([headerFooterViewClass isSubclassOfClass:[UITableViewHeaderFooterView class]]);
    
    NSString *className = [headerFooterViewClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    if ([UINib nibWithNameExists:className]) {
        
        [self
         registerNib:[UINib cachedNibWithName:className]
         forHeaderFooterViewReuseIdentifier:reuseIdentifier];
    }
    else {
        
        [self
         registerClass:headerFooterViewClass
         forHeaderFooterViewReuseIdentifier:reuseIdentifier];
    }
}

- (id)dequeueReusableCellWithClass:(Class)tableViewCellClass
                      forIndexPath:(NSIndexPath *)indexPath {
    
    return [self
            dequeueReusableCellWithClass:tableViewCellClass
            subIdentifier:nil
            forIndexPath:indexPath];
}

- (id)dequeueReusableCellWithClass:(Class)tableViewCellClass
                     subIdentifier:(NSString *)subIdentifier
                      forIndexPath:(NSIndexPath *)indexPath {
    
    JEAssertParameter([tableViewCellClass isSubclassOfClass:[UITableViewCell class]]);
    
    NSString *className = [tableViewCellClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    id cell = (indexPath
               ? [self dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath]
               : [self dequeueReusableCellWithIdentifier:reuseIdentifier]);
    JEAssert(!cell || [cell isKindOfClass:tableViewCellClass],
             @"Expected table view cell class \"%@\" from reuseIdentifier \"%@\" but dequeued a cell of type \"%@\" instead. Make sure that the reuseIdentifier for the %@ subclass is set to its class name",
             tableViewCellClass,
             reuseIdentifier,
             [cell class],
             [UITableViewCell class]);
    
    return (cell ?: [[tableViewCellClass alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:reuseIdentifier]);
}

- (id)dequeueReusableHeaderFooterViewWithClass:(Class)headerFooterViewClass {
    
    return [self dequeueReusableHeaderFooterViewWithClass:headerFooterViewClass subIdentifier:nil];
}

- (id)dequeueReusableHeaderFooterViewWithClass:(Class)headerFooterViewClass
                                 subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([headerFooterViewClass isSubclassOfClass:[UITableViewHeaderFooterView class]]);
    
    NSString *className = [headerFooterViewClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    id headerFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    JEAssert(!headerFooterView || [headerFooterView isKindOfClass:headerFooterViewClass],
             @"Expected table view header/footer class \"%@\" from reuseIdentifier \"%@\" but dequeued a view of type \"%@\" instead. Make sure that the reuseIdentifier for the %@ subclass is set to its class name",
             headerFooterViewClass,
             reuseIdentifier,
             [headerFooterView class],
             [UITableViewHeaderFooterView class]);
    
    return (headerFooterView ?: [[headerFooterViewClass alloc] initWithReuseIdentifier:reuseIdentifier]);
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass {
    
    return [self cellForQueryingHeightWithClass:tableViewCellClass subIdentifier:nil setupBlock:nil];
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass
                          setupBlock:(void (^)(id cell))setupBlock {
    
    return [self cellForQueryingHeightWithClass:tableViewCellClass subIdentifier:nil setupBlock:setupBlock];
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass
                       subIdentifier:(NSString *)subIdentifier {
    
    return [self cellForQueryingHeightWithClass:tableViewCellClass subIdentifier:subIdentifier setupBlock:nil];
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass
                       subIdentifier:(NSString *)subIdentifier
                          setupBlock:(void (^)(id cell))setupBlock {
    
    JEAssertParameter([tableViewCellClass isSubclassOfClass:[UITableViewCell class]]);
    
    NSString *className = [tableViewCellClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    NSCache *cache = [self cellHeightQueryingCache];
    if (!cache) {
        
        cache = [[NSCache alloc] init];
        [self setCellHeightQueryingCache:cache];
    }
    
    UITableViewCell *cell = [cache objectForKey:reuseIdentifier];
    if (!cell) {
        
        cell = [self
                dequeueReusableCellWithClass:tableViewCellClass
                subIdentifier:subIdentifier
                forIndexPath:nil];
        if (cell) {
            
            [cache setObject:cell forKey:reuseIdentifier];
        }
    }
    
    CGRect cellFrame = cell.frame;
    if (self.style == UITableViewStyleGrouped
        && ![self respondsToSelector:@selector(separatorInset)]) {
        
        cellFrame.size.width = (CGRectGetWidth(self.bounds)
                                - (2.0f * 20.0f)); // margin = 20pt
    }
    else {
        
        cellFrame.size.width = CGRectGetWidth(self.bounds);
    }
    cell.frame = cellFrame;
    
    if (setupBlock) {
        
        setupBlock(cell);
    }
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (id)headerFooterViewForQueryingHeightWithClass:(Class)headerFooterViewClass {
    
    return [self headerFooterViewForQueryingHeightWithClass:headerFooterViewClass subIdentifier:nil];
}

- (id)headerFooterViewForQueryingHeightWithClass:(Class)headerFooterViewClass
                                   subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([headerFooterViewClass isSubclassOfClass:[UITableViewHeaderFooterView class]]);
    
    NSString *className = [headerFooterViewClass classNameInAppModule];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    NSCache *cache = [self headerFooterViewHeightQueryingCache];
    UITableViewHeaderFooterView *view = [cache objectForKey:reuseIdentifier];
    if (!view) {
        
        view = [self
                dequeueReusableHeaderFooterViewWithClass:headerFooterViewClass
                subIdentifier:subIdentifier];
        if (view) {
            
            [cache setObject:view forKey:reuseIdentifier];
        }
    }
    
    CGRect viewFrame = view.frame;
    viewFrame.size.width = CGRectGetWidth(self.bounds);
    
    view.frame = viewFrame;
    [view layoutIfNeeded];
    
    return view;
}


@end
