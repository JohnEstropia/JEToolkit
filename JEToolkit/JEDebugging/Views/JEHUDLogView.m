//
//  JEHUDLogView.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEHUDLogView.h"

#import "JEFormulas.h"
#import "UILabel+JEToolkit.h"


static const CGFloat JEHUDLogViewButtonSize = 44.0f;
static const CGFloat JEHUDLogViewConsoleMinHeight = 100.0f;


@interface JEHUDLogView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) NSMutableArray *logEntries;

@property (nonatomic, weak) UIButton *toggleButton;
@property (nonatomic, weak) UIButton *resizeButton;
@property (nonatomic, weak) UIView *consoleView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) CAShapeLayer *toggleButtonMaskLayer;

@property (nonatomic, assign) BOOL isDraggingToggleButton;
@property (nonatomic, assign) BOOL isDraggingResizeButton;

@end


@implementation JEHUDLogView

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame
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
    consoleView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
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
    
    
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin
                                     | UIViewAutoresizingFlexibleBottomMargin);
    [toggleButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    toggleButton.selected = HUDLogSettings.visibleOnStart;
    toggleButton.frame = (CGRect){
        .origin.y = (CGRectGetMinY(consoleView.frame) - JEHUDLogViewButtonSize),
        .size.width = JEHUDLogViewButtonSize,
        .size.height = JEHUDLogViewButtonSize
    };
    toggleButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
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
    
    CALayer *toggleButtonLayer = toggleButton.layer;
    toggleButtonLayer.rasterizationScale = [UIScreen mainScreen].scale;
    toggleButtonLayer.shouldRasterize = YES;
    
    CAShapeLayer *toggleButtonMaskLayer = [[CAShapeLayer alloc] init];
    toggleButtonMaskLayer.frame = toggleButtonLayer.bounds;
    toggleButtonLayer.mask = toggleButtonMaskLayer;
    self.toggleButtonMaskLayer = toggleButtonMaskLayer;
    
    [self addSubview:toggleButton];
    self.toggleButton = toggleButton;
    
    
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
    resizeButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
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
    
    UIButton *toggleButton = self.toggleButton;
    CGRect toggleButtonFrame = toggleButton.frame;
    CGFloat toggleButtonHeight = CGRectGetHeight(toggleButtonFrame);
    toggleButton.frame = (CGRect){
        .origin.x = CGRectGetMinX(toggleButtonFrame),
        .origin.y = JEClamp(0.0f,
                            CGRectGetMinY(toggleButtonFrame),
                            (CGRectGetHeight(self.bounds)
                             - JEHUDLogViewConsoleMinHeight
                             - toggleButtonHeight)),
        .size = toggleButtonFrame.size
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
    CGFloat boundsWidth = CGRectGetWidth(tableView.bounds);
    CGSize constainSize = (CGSize){
        .width = boundsWidth,
        .height = CGFLOAT_MAX
    };
    NSString *logEntry = self.logEntries[indexPath.row];
    CGFloat heightForLabel = 0.0f;
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        constainSize.width -= 15.0f;
        heightForLabel = [logEntry
                          boundingRectWithSize:constainSize
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{ NSFontAttributeName : font,
                                        NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle] }
                          context:NULL].size.height;
    }
    else
    {
        constainSize.width -= 10.0f;
        heightForLabel = [logEntry
                          sizeWithFont:font
                          constrainedToSize:constainSize
                          lineBreakMode:NSLineBreakByWordWrapping].height;
    }
    
    return (15.0f + heightForLabel);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForIndexPath:indexPath];
    
    UILabel *textLabel = cell.textLabel;
    textLabel.text = self.logEntries[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate




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
    
    CGRect toggleButtonFrame = sender.frame;
    CGFloat toggleButtonHeight = CGRectGetHeight(toggleButtonFrame);
    sender.frame = (CGRect){
        .origin.x = CGRectGetMinX(toggleButtonFrame),
        .origin.y = JEClamp(0.0f,
                            (location.y - (toggleButtonHeight * 0.5f)),
                            (CGRectGetHeight(self.bounds)
                             - JEHUDLogViewConsoleMinHeight
                             - toggleButtonHeight)),
        .size = toggleButtonFrame.size
    };
    
    [self layoutConsoleView];
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
    
    CAShapeLayer *toggleButtonMaskLayer = self.toggleButtonMaskLayer;
    if (consoleHidden)
    {
        toggleButtonMaskLayer.path = [UIBezierPath
                                      bezierPathWithRoundedRect:toggleButtonMaskLayer.bounds
                                      byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                      cornerRadii:(CGSize){ .width = 8.0f, .height = 8.0f }].CGPath;
        return;
    }
    toggleButtonMaskLayer.path = [UIBezierPath
                                  bezierPathWithRoundedRect:toggleButtonMaskLayer.bounds
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView = [[UIView alloc] init];
        
        UILabel *textLabel = cell.textLabel;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont systemFontOfSize:10.0f];
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
    
    UIButton *toggleButton = self.toggleButton;
    CGFloat toggleButtonBottom = CGRectGetMaxY(toggleButton.frame);
    
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
            .origin.y = JEClamp((CGRectGetMaxY(toggleButton.frame) + JEHUDLogViewConsoleMinHeight),
                                resizeButtonTop,
                                boundsHeight),
            .size = resizeButtonFrame.size
        };
        consoleView.frame = (CGRect){
            .origin.x = 0.0f,
            .origin.y = toggleButtonBottom,
            .size.width = CGRectGetWidth(bounds),
            .size.height = (CGRectGetMinY(resizeButton.frame) - toggleButtonBottom)
        };
    }
    else
    {
        consoleView.frame = (CGRect){
            .origin.x = 0.0f,
            .origin.y = toggleButtonBottom,
            .size.width = CGRectGetWidth(bounds),
            .size.height = JEClamp(JEHUDLogViewConsoleMinHeight,
                                   CGRectGetHeight(consoleView.frame),
                                   (boundsHeight - toggleButtonBottom))
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
    NSCParameterAssert(logString);
    NSCParameterAssert(HUDLogSettings);
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
