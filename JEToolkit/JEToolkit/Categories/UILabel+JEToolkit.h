//
//  UILabel+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (JEToolkit)

/*! Computes for the display size of the receiver's current text.
 */
- (CGSize)sizeForText;

/*! Computes for the display size of the receiver's current attributesText.
 */
- (CGSize)sizeForAttributedText;

@end
