//
//  UITableView+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/01.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UITableView+JEToolkit.h"

#import "NSObject+JEToolkit.h"
#import "UINib+JEToolkit.h"

#import "JESynthesize.h"
#import "JEDebugging.h"


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
