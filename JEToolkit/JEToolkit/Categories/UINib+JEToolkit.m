//
//  UINib+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/01.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UINib+JEToolkit.h"

@implementation UINib (JEToolkit)

+ (UINib *)cachedNibWithName:(NSString *)nibName {
    
    static NSCache *nibCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        nibCache = [NSCache new];
        
    });
    
    UINib *nib = [nibCache objectForKey:nibName];
    if (!nib) {
        
        nib = [UINib nibWithNibName:nibName bundle:nil];
        if (nib) {
            
            [nibCache setObject:nib forKey:nibName];
        }
    }
    return nib;
}

@end
