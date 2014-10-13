//
//  JEUIMetrics.h
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

#ifndef JEToolkit_JEUIMetrics_h
#define JEToolkit_JEUIMetrics_h


#pragma mark - Device Metrics

static const CGSize JEUIIPhone4ScreenPortraitSize = (CGSize){ .width = 320.0f, .height = 480.0f };
static const CGSize JEUIIPhone4ScreenLandscapeSize = (CGSize){ .width = 480.0f, .height = 320.0f };

static const CGSize JEUIIPhone5ScreenPortraitSize = (CGSize){ .width = 320.0f, .height = 568.0f };
static const CGSize JEUIIPhone5ScreenLandscapeSize = (CGSize){ .width = 568.0f, .height = 320.0f };

static const CGSize JEUIIPadScreenPortraitSize = (CGSize){ .width = 768.0f, .height = 1024.0f };
static const CGSize JEUIIPadScreenLandscapeSize = (CGSize){ .width = 1024.0f, .height = 768.0f };


#pragma mark - Views

static const CGFloat JEUIAdBannerViewHeight = 50.0f;
static const CGFloat JEUIPickerViewHeight = 216.0f;
static const CGFloat JEUITextFieldHeight = 31.0f;
static const CGFloat JEUIToolbarHeight = 44.0f;

static const CGFloat JEUINavigationBarLandscapeHeight = 32.0f;
static const CGFloat JEUINavigationBarPortraitHeight = 44.0f;

static const CGFloat JEUIStatusBarHeight = 20.0f;
static const CGFloat JEUITableViewSeparatorWidth = 1.0f;

static const CGFloat JEUITabBarHeight = 49.0f;


#endif
