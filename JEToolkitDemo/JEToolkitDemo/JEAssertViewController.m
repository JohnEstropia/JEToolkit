//
//  JEAssertViewController.m
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 10/13/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEAssertViewController.h"

#import <JEToolkit/JEToolkit.h>


typedef NS_ENUM(NSInteger, JEAssertSamplesRow) {
    
    JEAssertSamplesRowAssert = 0,
    JEAssertSamplesRowAssertParameter,
    JEAssertSamplesRowAssertMainThread,
    JEAssertSamplesRowAssertBackgroundThread,
    
    _JEAssertSamplesRowCount
};

@implementation JEAssertViewController

#pragma mark - BaseSourceCodeSamplerController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text;
    switch (indexPath.row) {
            
        case JEAssertSamplesRowAssert:
            text = @"JEAssert(100 > 900, @\"This exception was raised to test exception logging\");";
            break;
            
        case JEAssertSamplesRowAssertParameter:
            text = @"JEAssertParameter(nonNilObject != nil);";
            break;
            
        case JEAssertSamplesRowAssertMainThread:
            text = @"JEAssertMainThread();";
            break;
            
        case JEAssertSamplesRowAssertBackgroundThread:
            text = @"JEAssertBackgroundThread();";
            break;
            
        default:
            break;
    }
    cell.textLabel.text = text;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case JEAssertSamplesRowAssert:
            [self executeAssertFailure];
            break;
            
        case JEAssertSamplesRowAssertParameter:
            [self executeAssertParameterFailureForInvalidParameter:nil];
            break;
            
        case JEAssertSamplesRowAssertMainThread: {
            JEDispatchConcurrent(^{
                
                [self executeAssertMainThreadFailure];
                
            });
            break;
        }
            
        case JEAssertSamplesRowAssertBackgroundThread: {
            JEDispatchUI(^{
                
                [self executeAssertBackgroundThreadFailure];
                
            });
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _JEAssertSamplesRowCount;
}


#pragma mark - Private

- (void)executeAssertFailure {
    
    @try {
        
        JEAssert(100 > 900, @"This exception was raised to test exception logging");
    }
    @catch (NSException *exception) {
        
        JEDumpAlert(exception);
    }
}

- (void)executeAssertParameterFailureForInvalidParameter:(NSObject *)nonNilObject {
    
    @try {
        
        JEAssertParameter(nonNilObject != nil);
    }
    @catch (NSException *exception) {
        
        JEDumpAlert(exception);
    }
}

- (void)executeAssertMainThreadFailure {
    
    @try {
        
        JEAssertMainThread();
    }
    @catch (NSException *exception) {
        
        JEDumpAlert(exception);
    }
}

- (void)executeAssertBackgroundThreadFailure {
    
    @try {
        
        JEAssertBackgroundThread();
    }
    @catch (NSException *exception) {
        
        JEDumpAlert(exception);
    }
}


@end
