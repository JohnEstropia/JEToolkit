//
//  JELogViewController.m
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 10/13/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JELogViewController.h"

#import <JEToolkit/JEToolkit.h>


typedef NS_ENUM(NSInteger, JELogSamplesRow) {
    
    JELogSamplesRowTrace = 0,
    JELogSamplesRowNotice,
    JELogSamplesRowAlert,
    JELogSamplesRowFatal,
    
    _JELogSamplesRowCount
};


@implementation JELogViewController

#pragma mark - BaseSourceCodeSamplerController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text;
    switch (indexPath.row) {
            
        case JELogSamplesRowTrace:
            text = @"JELog(@\"This is a sample log (row: %d)\", indexPath.row);";
            break;
            
        case JELogSamplesRowNotice:
            text = @"JELogNotice(@\"This is a notice-level log (row: %d)\", indexPath.row);";
            break;
            
        case JELogSamplesRowAlert:
            text = @"JELogAlert(@\"This is an alert-level log (row: %d)\", indexPath.row);";
            break;
            
        case JELogSamplesRowFatal:
            text = @"JELogFatal(@\"This is a fatal-level log (row: %d)\", indexPath.row);";
            break;
            
        default:
            break;
    }
    cell.textLabel.text = text;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case JELogSamplesRowTrace:
            JELog(@"This is a sample log (row: %d)", (int)indexPath.row);
            break;
            
        case JELogSamplesRowNotice:
            JELogNotice(@"This is a notice-level log (row: %d)", (int)indexPath.row);
            break;
            
        case JELogSamplesRowAlert:
            JELogAlert(@"This is an alert-level log (row: %d)", (int)indexPath.row);
            break;
            
        case JELogSamplesRowFatal:
            JELogFatal(@"This is a fatal-level log (row: %d)", (int)indexPath.row);
            break;
            
        default:
            break;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _JELogSamplesRowCount;
}

@end
