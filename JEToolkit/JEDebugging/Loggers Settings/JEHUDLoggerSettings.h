//
//  JEHUDLoggerSettings.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
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

#import "JEBaseLoggerSettings.h"

/*! JEFileLoggerSettings provides configurations to the in-app HUD console.
 */
@interface JEHUDLoggerSettings : JEBaseLoggerSettings

/*! The combination of JELogLevelMask flags that will be output by the HUD logger. Defaults to JELogLevelAll for debug builds, JELogLevelNone for release builds
 */
@property (nonatomic, assign) JELogLevelMask logLevelMask;

/*! The combination of JELogMessageHeaderMask flags for log headers that will be displayed by the HUD logger. Defaults to (JELogMessageHeaderSourceFile | JELogMessageHeaderFunction)
 */
@property (nonatomic, assign) JELogMessageHeaderMask logMessageHeaderMask;

/*! Set to YES if the HUD log should be expanded when +[JEDebugging start] is called. Set to NO if the HUD log should stay collapsed. Defaults to NO
 */
@property (nonatomic, assign) BOOL visibleOnStart;

/*! The starting position of the toggle button on start. Set to a value from 0.0 (right below the statusbar) to 1.0 (the lowest expandable position). Defaults to 1.0.
 */
@property (nonatomic, assign) float buttonOffsetOnStart;

/*! The maximum number of log entries at a time displayed on the HUD log. Defaults to 200 entries
 */
@property (nonatomic, assign) NSUInteger numberOfLogEntriesInMemory;

@end
