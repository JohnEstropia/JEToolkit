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
#endif


@implementation UITableView (JEToolkit)

#pragma mark - Private

JESynthesize(strong, NSCache *, cellHeightQueryingCache, setCellHeightQueryingCache);


#pragma mark - Public

- (void)registerTableViewCellClass:(Class)tableViewCellClass {
    
    [self registerTableViewCellClass:tableViewCellClass subIdentifier:nil];
}

- (void)registerTableViewCellClass:(Class)tableViewCellClass
                     subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([tableViewCellClass isSubclassOfClass:[UITableViewCell class]]);
    
    NSString *className = [tableViewCellClass className];
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
    
    NSString *className = [tableViewCellClass className];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    return ((indexPath
             ? [self dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath]
             : [self dequeueReusableCellWithIdentifier:reuseIdentifier])
            ?: [[tableViewCellClass alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier]);
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass {
    
    return [self cellForQueryingHeightWithClass:tableViewCellClass subIdentifier:nil];
}

- (id)cellForQueryingHeightWithClass:(Class)tableViewCellClass subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([tableViewCellClass isSubclassOfClass:[UITableViewCell class]]);
    
    NSString *className = [tableViewCellClass className];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    
    NSCache *cache = [self cellHeightQueryingCache];
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
    [cell layoutIfNeeded];
    
    return cell;
}


@end
