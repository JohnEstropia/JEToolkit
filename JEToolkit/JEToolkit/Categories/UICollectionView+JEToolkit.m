//
//  UICollectionView+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/01.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UICollectionView+JEToolkit.h"

#import "NSObject+JEToolkit.h"
#import "UINib+JEToolkit.h"

#import "JEDebugging.h"


@implementation UICollectionView (JEToolkit)

- (void)registerCollectionViewCellClass:(Class)collectionViewCellClass {
    
    [self registerCollectionViewCellClass:collectionViewCellClass subIdentifier:nil];
}

- (void)registerCollectionViewCellClass:(Class)collectionViewCellClass
                          subIdentifier:(NSString *)subIdentifier {
    
    JEAssertParameter([collectionViewCellClass isSubclassOfClass:[UICollectionViewCell class]]);
    
    NSString *className = [collectionViewCellClass className];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    if ([UINib nibWithNameExists:className]) {
        
        [self
         registerNib:[UINib cachedNibWithName:className]
         forCellWithReuseIdentifier:reuseIdentifier];
    }
    else {
        
        [self
         registerClass:collectionViewCellClass
         forCellWithReuseIdentifier:reuseIdentifier];
    }
}

- (id)dequeueReusableCellWithClass:(Class)collectionViewCellClass
                      forIndexPath:(NSIndexPath *)indexPath {
    
    return [self
            dequeueReusableCellWithClass:collectionViewCellClass
            subIdentifier:nil
            forIndexPath:indexPath];
}

- (id)dequeueReusableCellWithClass:(Class)collectionViewCellClass
                     subIdentifier:(NSString *)subIdentifier
                      forIndexPath:(NSIndexPath *)indexPath {
    
    JEAssertParameter([collectionViewCellClass isSubclassOfClass:[UICollectionViewCell class]]);
    JEAssertParameter(indexPath != nil);
    
    NSString *className = [collectionViewCellClass className];
    NSString *reuseIdentifier = className;
    if (subIdentifier) {
        
        reuseIdentifier = [className stringByAppendingString:subIdentifier];
    }
    id cell = [self
               dequeueReusableCellWithReuseIdentifier:reuseIdentifier
               forIndexPath:indexPath];
    if (!cell) {
        
        cell = [[collectionViewCellClass alloc] initWithFrame:CGRectZero];
    }
    
    return cell;
}

@end
