//
//  BaseSourceCodeSamplerController.m
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 10/13/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "BaseSourceCodeSamplerController.h"

#import <JEToolkit/JEToolkit.h>

static const CGFloat UITableViewCellMargin = 10.0f;


@implementation BaseSourceCodeSamplerController

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithClass:[UITableViewCell class] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForQueryingHeightWithClass:[UITableViewCell class] setupBlock:^(UITableViewCell *cell) {
        
        [self configureCell:cell atIndexPath:indexPath];
    }];
    return MAX(tableView.rowHeight,
               (CGRectGetHeight(cell.bounds)
                - CGRectGetHeight(cell.textLabel.frame)
                + [cell.textLabel sizeForText].height
                + JEUITableViewSeparatorWidth
                + (UITableViewCellMargin * 2.0f))); // separator width
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didSelectCellAtIndexPath:indexPath];
}


#pragma mark - Public

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // subclass override
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    // subclass override
}

@end
