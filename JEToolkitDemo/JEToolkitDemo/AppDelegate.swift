//
//  AppDelegate.swift
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 2014/10/05.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

import UIKit
import JEToolkit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let consoleLoggerSettings = JEDebugging.copyConsoleLoggerSettings()
        let HUDLoggerSettings = JEDebugging.copyHUDLoggerSettings()
        let fileLoggerSettings = JEDebugging.copyFileLoggerSettings()
        
        // These are the actual default logging level masks declared for debug and release modes.
        // For other configurable settings, refer to the JEConsoleLoggerSettings, JEHUDLoggerSettings, and JEFileLoggerSettings classes.
        #if DEBUG
            
            consoleLoggerSettings.logLevelMask = .All
            HUDLoggerSettings.logLevelMask = .All
            fileLoggerSettings.logLevelMask = (.Notice | .Alert)
            
            #else
            
            consoleLoggerSettings.logLevelMask = (.Notice | .Alert)
            HUDLoggerSettings.logLevelMask = .None
            fileLoggerSettings.logLevelMask = (.Notice | .Alert)
            
        #endif
        
        JEDebugging.setConsoleLoggerSettings(consoleLoggerSettings)
        JEDebugging.setHUDLoggerSettings(HUDLoggerSettings)
        JEDebugging.setFileLoggerSettings(fileLoggerSettings)
        
        // Note that this will detach previously set exception handlers, such as handlers provided by analytics frameworks or other debugging frameworks.
        JEDebugging.setExceptionLoggingEnabled(true)
        JEDebugging.setApplicationLifecycleLoggingEnabled(true)
        
        JEDebugging.start()
        
        JEDebugging.logLevel(
            .Notice,
            location:JELogLocation(fileName: nil, functionName: nil, lineNumber: 0),
            format: "isDebugBuild = %@, isDebuggerRunning = %@",
            arguments: getVaList([JEDebugging.isDebugBuild(), JEDebugging.isDebuggerAttached()]))
        
        return true
    }
}

