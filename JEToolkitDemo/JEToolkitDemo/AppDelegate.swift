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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // The actual default logging level masks for debug and release modes are set with consideration to performance and privacy. (For example, The HUD logger is disabled on release mode)
        // For other configurable settings, refer to the JEConsoleLoggerSettings, JEHUDLoggerSettings, and JEFileLoggerSettings classes.
        
        let consoleLoggerSettings = JEDebugging.copyConsoleLoggerSettings()
        consoleLoggerSettings.logLevelMask = .all
        JEDebugging.setConsoleLoggerSettings(consoleLoggerSettings)
        
        let HUDLoggerSettings = JEDebugging.copyHUDLoggerSettings()
        HUDLoggerSettings.logLevelMask = .all
        HUDLoggerSettings.visibleOnStart = false
        HUDLoggerSettings.buttonOffsetOnStart = 1.0
        JEDebugging.setHUDLoggerSettings(HUDLoggerSettings)
        
        let fileLoggerSettings = JEDebugging.copyFileLoggerSettings()
        fileLoggerSettings.logLevelMask = [.notice, .alert]
        JEDebugging.setFileLoggerSettings(fileLoggerSettings)
        
        // Note that this will detach previously set exception handlers, such as handlers provided by analytics frameworks or other debugging frameworks.
        JEDebugging.setExceptionLoggingEnabled(true)
        JEDebugging.setApplicationLifeCycleLoggingEnabled(true)
        
        JEDebugging.start()
        
        return true
    }
}

