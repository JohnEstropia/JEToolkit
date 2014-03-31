//
//  JEHUDLogView.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEHUDLogView.h"

#import "JEFormulas.h"
#import "UIImage+JEToolkit.h"
#import "UILabel+JEToolkit.h"
#import "UIView+JEToolkit.h"


static NSString *const JEHUDCellReuseIdentifier = @"cell";

static const CGFloat JEHUDLogViewButtonSize = 44.0f;
static const CGFloat JEHUDLogViewConsoleMinHeight = 100.0f;


@interface JEHUDLogView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) NSMutableArray *logEntries;

@property (nonatomic, weak) UIView *menuView;
@property (nonatomic, weak) CAShapeLayer *menuMaskLayer;
@property (nonatomic, weak) UIButton *toggleButton;
@property (nonatomic, weak) UIButton *screenshotButton;
@property (nonatomic, weak) UIButton *resizeButton;
@property (nonatomic, weak) UIView *consoleView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) BOOL isDraggingToggleButton;
@property (nonatomic, assign) BOOL isDraggingResizeButton;

@end


@implementation JEHUDLogView

#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame
           threadSafeSettings:(JEHUDLoggerSettings *)HUDLogSettings
{
    self = [super initWithFrame:frame];
    if (!self)
    {
        return nil;
    }
    
    _logEntries = [[NSMutableArray alloc] initWithCapacity:HUDLogSettings.numberOfLogEntriesInMemory];
    self.backgroundColor = [UIColor clearColor];
    
    CGRect bounds = self.bounds;
    
    UIView *consoleView = [[UIView alloc] initWithFrame:(CGRect){
        .origin.y = (CGRectGetHeight(bounds) - JEHUDLogViewConsoleMinHeight),
        .size.width = CGRectGetWidth(bounds),
        .size.height = JEHUDLogViewConsoleMinHeight
    }];
    [consoleView setTranslatesAutoresizingMaskIntoConstraints:YES];
    consoleView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    [self addSubview:consoleView];
    self.consoleView = consoleView;
    
    
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame:CGRectInset(consoleView.bounds, 0.0f, 5.0f)
                              style:UITableViewStylePlain];
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight);
    [tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.directionalLockEnabled = YES;
    tableView.showsHorizontalScrollIndicator = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.allowsSelection = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        tableView.separatorInset = (UIEdgeInsets){ .left = 10.0f, .right = 10.0f };
    }
    tableView.contentInset = tableView.scrollIndicatorInsets;
    tableView.dataSource = self;
    tableView.delegate = self;
    [consoleView addSubview:tableView];
    self.tableView = tableView;
    
    
    UIView *menuView = [[UIView alloc] initWithFrame:(CGRect){
        .origin.y = (CGRectGetMinY(consoleView.frame) - JEHUDLogViewButtonSize),
        .size.width = JEHUDLogViewButtonSize,
        .size.height = JEHUDLogViewButtonSize
    }];
    menuView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin
                                 | UIViewAutoresizingFlexibleBottomMargin);
    [menuView setTranslatesAutoresizingMaskIntoConstraints:YES];
    menuView.backgroundColor = consoleView.backgroundColor;
    
    CALayer *menuLayer = menuView.layer;
    menuLayer.rasterizationScale = [UIScreen mainScreen].scale;
    menuLayer.shouldRasterize = YES;
    
    CAShapeLayer *menuMaskLayer = [[CAShapeLayer alloc] init];
    menuMaskLayer.frame = menuLayer.bounds;
    menuLayer.mask = menuMaskLayer;
    self.menuMaskLayer = menuMaskLayer;
    
    [self addSubview:menuView];
    self.menuView = menuView;
    
    
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin
                                     | UIViewAutoresizingFlexibleBottomMargin);
    [toggleButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    toggleButton.selected = HUDLogSettings.visibleOnStart;
    toggleButton.frame = (CGRect){
        .size.width = JEHUDLogViewButtonSize,
        .size.height = JEHUDLogViewButtonSize
    };
    toggleButton.backgroundColor = [UIColor clearColor];
    toggleButton.showsTouchWhenHighlighted = YES;
    [toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [toggleButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateHighlighted];
    [toggleButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [toggleButton setTitle:@"▼" forState:UIControlStateNormal];
    [toggleButton setTitle:@"▼" forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [toggleButton setTitle:@"▲" forState:UIControlStateSelected];
    [toggleButton setTitle:@"▲" forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [toggleButton
     addTarget:self
     action:@selector(toggleButtonTouchUpInside:)
     forControlEvents:UIControlEventTouchUpInside];
    [toggleButton
     addTarget:self
     action:@selector(toggleButtonTouchEnd:)
     forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    [toggleButton
     addTarget:self
     action:@selector(toggleButtonTouchDrag:withEvent:)
     forControlEvents:(UIControlEventTouchDragInside | UIControlEventTouchDragOutside)];
    [menuView addSubview:toggleButton];
    self.toggleButton = toggleButton;
    
    
    UIButton *screenshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    screenshotButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin
                                         | UIViewAutoresizingFlexibleBottomMargin);
    [screenshotButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    screenshotButton.frame = (CGRect){
        .origin.x = CGRectGetMaxX(toggleButton.frame),
        .size.width = JEHUDLogViewButtonSize,
        .size.height = JEHUDLogViewButtonSize
    };
    screenshotButton.backgroundColor = [UIColor clearColor];
    screenshotButton.showsTouchWhenHighlighted = YES;
    [screenshotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [screenshotButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateHighlighted];
    [screenshotButton setTitle:@"📷" forState:UIControlStateNormal];
    [screenshotButton
     addTarget:self
     action:@selector(screenshotButtonTouchUpInside:)
     forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:screenshotButton];
    self.screenshotButton = screenshotButton;
    
    
    UIButton *resizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resizeButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin
                                     | UIViewAutoresizingFlexibleBottomMargin);
    [resizeButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    resizeButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(bounds) - JEHUDLogViewButtonSize),
        .origin.y = CGRectGetMaxY(consoleView.frame),
        .size.width = JEHUDLogViewButtonSize,
        .size.height = JEHUDLogViewButtonSize
    };
    resizeButton.backgroundColor = consoleView.backgroundColor;
    resizeButton.showsTouchWhenHighlighted = YES;
    [resizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resizeButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateHighlighted];
    [resizeButton setTitle:@"▼" forState:UIControlStateNormal];
    [resizeButton
     addTarget:self
     action:@selector(resizeButtonTouchEnd:)
     forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    [resizeButton
     addTarget:self
     action:@selector(resizeButtonTouchDrag:withEvent:)
     forControlEvents:(UIControlEventTouchDragInside | UIControlEventTouchDragOutside)];
    
    CALayer *resizeButtonLayer = resizeButton.layer;
    resizeButtonLayer.rasterizationScale = [UIScreen mainScreen].scale;
    resizeButtonLayer.shouldRasterize = YES;
    
    CAShapeLayer *resizeButtonMaskLayer = [[CAShapeLayer alloc] init];
    resizeButtonMaskLayer.frame = resizeButtonLayer.bounds;
    resizeButtonMaskLayer.path = [UIBezierPath
                                  bezierPathWithRoundedRect:resizeButtonMaskLayer.bounds
                                  byRoundingCorners:UIRectCornerBottomLeft
                                  cornerRadii:(CGSize){ .width = 8.0f, .height = 8.0f }].CGPath;
    resizeButtonLayer.mask = resizeButtonMaskLayer;
    
    [self addSubview:resizeButton];
    self.resizeButton = resizeButton;
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidChangeStatusBarOrientation:)
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:[UIApplication sharedApplication]];
    [self applicationDidChangeStatusBarOrientation:nil];
    
    
    [self didUpdateHUDVisibility];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:[UIApplication sharedApplication]];
}


#pragma mark - UIResponder

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self ? nil : view);
}


#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *menuView = self.menuView;
    CGRect menuFrame = menuView.frame;
    menuView.frame = (CGRect){
        .origin.x = CGRectGetMinX(menuFrame),
        .origin.y = JEClamp(0.0f,
                            CGRectGetMinY(menuFrame),
                            (CGRectGetHeight(self.bounds)
                             - JEHUDLogViewConsoleMinHeight
                             - CGRectGetHeight(menuFrame))),
        .size = menuFrame.size
    };
    
    [self layoutConsoleView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logEntries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UITableViewCell *dummyCell;
    if (!dummyCell)
    {
        dummyCell = [self cellForIndexPath:nil];
    }
    
    dummyCell.frame = (CGRect){
        .size.width = CGRectGetHeight(tableView.bounds),
        .size.height = 20.0f
    };
    
    UILabel *textLabel = dummyCell.textLabel;
    textLabel.text = self.logEntries[indexPath.row];
    
    return ceilf((CGRectGetHeight(dummyCell.bounds)
                  - CGRectGetHeight(textLabel.frame)
                  + [textLabel sizeForText].height
                  + 10.0f));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForIndexPath:indexPath];
    
    UILabel *textLabel = cell.textLabel;
    textLabel.text = self.logEntries[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = nil;
}


#pragma mark - @selector

- (void)toggleButtonTouchUpInside:(UIButton *)sender
{
    if (self.isDraggingToggleButton)
    {
        self.isDraggingToggleButton = NO;
        return;
    }
    
    sender.selected = !sender.selected;
    [self didUpdateHUDVisibility];
}

- (void)toggleButtonTouchEnd:(UIButton *)sender
{
    self.isDraggingToggleButton = NO;
}

- (void)toggleButtonTouchDrag:(UIButton *)sender withEvent:(UIEvent *)event
{
    self.isDraggingToggleButton = YES;
    
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self];
    
    UIView *menuView = self.menuView;
    CGRect menuFrame = menuView.frame;
    CGFloat menuHeight = CGRectGetHeight(menuFrame);
    menuView.frame = (CGRect){
        .origin.x = CGRectGetMinX(menuFrame),
        .origin.y = JEClamp(0.0f,
                            (location.y - (menuHeight * 0.5f)),
                            (CGRectGetHeight(self.bounds)
                             - JEHUDLogViewConsoleMinHeight
                             - menuHeight)),
        .size = menuFrame.size
    };
    
    [self layoutConsoleView];
}

- (void)screenshotButtonTouchUpInside:(UIButton *)sender
{
    UIView *menuView = self.menuView;
    UIView *consoleView = self.consoleView;
    UIButton *resizeButton = self.resizeButton;
    
    BOOL menuHidden = menuView.hidden;
    BOOL consoleHidden = consoleView.hidden;
    BOOL resizeButtonHidden = resizeButton.hidden;
    
    menuView.hidden = YES;
    consoleView.hidden = YES;
    resizeButton.hidden = YES;
    
    UIImage *screenshot = [UIImage screenshot];
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, NULL, NULL);
    
    menuView.hidden = menuHidden;
    consoleView.hidden = consoleHidden;
    resizeButton.hidden = resizeButtonHidden;
}

- (void)resizeButtonTouchEnd:(UIButton *)sender
{
    self.isDraggingResizeButton = NO;
}

- (void)resizeButtonTouchDrag:(UIButton *)sender withEvent:(UIEvent *)event
{
    self.isDraggingResizeButton = YES;
    
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self];
    
    CGRect resizeButtonFrame = sender.frame;
    CGFloat resizeButtonHeight = CGRectGetHeight(resizeButtonFrame);
    sender.frame = (CGRect){
        .origin.x = CGRectGetMinX(resizeButtonFrame),
        .origin.y = JEClamp((CGRectGetMaxY(self.toggleButton.frame) + JEHUDLogViewConsoleMinHeight),
                            (location.y - (resizeButtonHeight * 0.5f)),
                            CGRectGetHeight(self.bounds)),
        .size = resizeButtonFrame.size
    };
    
    [self layoutConsoleView];
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)note
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = [UIScreen mainScreen].bounds;
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            bounds.size = (CGSize){ .width = CGRectGetHeight(bounds), .height = CGRectGetWidth(bounds) };
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            bounds.size = (CGSize){ .width = CGRectGetHeight(bounds), .height = CGRectGetWidth(bounds) };
            break;
    }
    self.transform = transform;
    self.bounds = bounds;
}


#pragma mark - Private

- (void)didUpdateHUDVisibility
{
    BOOL consoleHidden = !self.toggleButton.selected;
    self.consoleView.hidden = consoleHidden;
    self.resizeButton.hidden = consoleHidden;
    
    UIButton *screenshotButton = self.screenshotButton;
    screenshotButton.hidden = consoleHidden;
    
    UIView *menuView = self.menuView;
    CGRect menuFrame = menuView.frame;
    
    CAShapeLayer *menuMaskLayer = self.menuMaskLayer;
    if (consoleHidden)
    {
        menuView.frame = (CGRect){
            .origin = menuFrame.origin,
            .size.width = CGRectGetMinX(screenshotButton.frame),
            .size.height = CGRectGetHeight(menuFrame)
        };
        menuMaskLayer.frame = menuView.layer.bounds;
        menuMaskLayer.path = [UIBezierPath
                              bezierPathWithRoundedRect:menuMaskLayer.bounds
                              byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                              cornerRadii:(CGSize){ .width = 8.0f, .height = 8.0f }].CGPath;
        return;
    }
    
    menuView.frame = (CGRect){
        .origin = menuFrame.origin,
        .size.width = CGRectGetMaxX(screenshotButton.frame),
        .size.height = CGRectGetHeight(menuFrame)
    };
    menuMaskLayer.frame = menuView.layer.bounds;
    menuMaskLayer.path = [UIBezierPath
                          bezierPathWithRoundedRect:menuMaskLayer.bounds
                          byRoundingCorners:UIRectCornerTopRight
                          cornerRadii:(CGSize){ .width = 8.0f, .height = 8.0f }].CGPath;
    
    UITableView *tableView = self.tableView;
    [tableView reloadData];
    
    NSUInteger numberOfLogEntries = [self.logEntries count];
    if (numberOfLogEntries <= 0)
    {
        return;
    }
    
    [tableView
     scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfLogEntries - 1) inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom
     animated:NO];
    [tableView flashScrollIndicators];
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (indexPath
                             ? [self.tableView
                                dequeueReusableCellWithIdentifier:JEHUDCellReuseIdentifier]
                             : nil);
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JEHUDCellReuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView = [[UIView alloc] init];
        
        UILabel *textLabel = cell.textLabel;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont fontWithName:@"Courier" size:10.0f];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 0;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

- (void)layoutConsoleView
{
    CGRect bounds = self.bounds;
    CGFloat boundsHeight = CGRectGetHeight(bounds);
    
    UIView *menuView = self.menuView;
    CGRect menuFrame = menuView.frame;
    CGFloat menuBottom = CGRectGetMaxY(menuFrame);
    
    UIButton *resizeButton = self.resizeButton;
    CGRect resizeButtonFrame = resizeButton.frame;
    
    UIView *consoleView = self.consoleView;
    if (self.isDraggingResizeButton)
    {
        CGFloat resizeButtonTop = CGRectGetMinY(resizeButtonFrame);
        if (resizeButtonTop > (boundsHeight - CGRectGetHeight(resizeButtonFrame)))
        {
            resizeButtonTop = boundsHeight;
        }
        resizeButton.frame = (CGRect){
            .origin.x = CGRectGetMinX(resizeButtonFrame),
            .origin.y = JEClamp((CGRectGetMaxY(menuFrame) + JEHUDLogViewConsoleMinHeight),
                                resizeButtonTop,
                                boundsHeight),
            .size = resizeButtonFrame.size
        };
        consoleView.frame = (CGRect){
            .origin.x = 0.0f,
            .origin.y = menuBottom,
            .size.width = CGRectGetWidth(bounds),
            .size.height = (CGRectGetMinY(resizeButton.frame) - menuBottom)
        };
    }
    else
    {
        consoleView.frame = (CGRect){
            .origin.x = 0.0f,
            .origin.y = menuBottom,
            .size.width = CGRectGetWidth(bounds),
            .size.height = JEClamp(JEHUDLogViewConsoleMinHeight,
                                   CGRectGetHeight(consoleView.frame),
                                   (boundsHeight - menuBottom))
        };
        resizeButton.frame = (CGRect){
            .origin.x = CGRectGetMinX(resizeButtonFrame),
            .origin.y = CGRectGetMaxY(consoleView.frame),
            .size = resizeButtonFrame.size
        };
    }
}



#pragma mark - Public

- (void)addLogString:(NSString *)logString
withThreadSafeSettings:(JEHUDLoggerSettings *)HUDLogSettings
{
    NSCParameterAssert(logString != nil);
    NSCParameterAssert(HUDLogSettings != nil);
    NSCAssert([NSThread isMainThread],
              @"%@ called on the wrong queue.", NSStringFromSelector(_cmd));
    
    UITableView *tableView = self.tableView;
    CGRect scrollBounds = tableView.bounds;
    BOOL shouldScrollToBottom = (!(tableView.tracking || tableView.dragging)
                                 && (truncf(tableView.contentOffset.y)
                                     >= truncf(tableView.contentSize.height - CGRectGetHeight(scrollBounds))));
    
    NSMutableArray *logEntries = self.logEntries;
    NSUInteger numberOfLogEntries = [logEntries count];
    
    NSMutableArray *indexPathsToDelete;
    NSUInteger maxNumberOfLogEntriesInMemory = HUDLogSettings.numberOfLogEntriesInMemory;
    if (numberOfLogEntries >= maxNumberOfLogEntriesInMemory)
    {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:(NSRange){
            .location = 0,
            .length = (numberOfLogEntries - maxNumberOfLogEntriesInMemory)
        }];
        [logEntries removeObjectsAtIndexes:indexSet];
        
        indexPathsToDelete = [[NSMutableArray alloc] initWithCapacity:[indexSet count]];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            
        }];
    }
    
    [logEntries addObject:logString];
    
    if (self.consoleView.hidden)
    {
        return;
    }
    
    NSUInteger newNumberOfLogEntries = [logEntries count];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(newNumberOfLogEntries - 1) inSection:0];
    if (numberOfLogEntries == newNumberOfLogEntries)
    {
        [tableView reloadData];
    }
    else
    {
        [tableView beginUpdates];
        if (indexPathsToDelete)
        {
            [tableView
             deleteRowsAtIndexPaths:indexPathsToDelete
             withRowAnimation:UITableViewRowAnimationNone];
        }
        [tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
    
    if (shouldScrollToBottom)
    {
        [tableView
         scrollToRowAtIndexPath:newIndexPath
         atScrollPosition:UITableViewScrollPositionBottom
         animated:NO];
    }
}

@end
