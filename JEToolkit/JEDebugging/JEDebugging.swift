//
//  JEDebugging.swift
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

import Foundation


// MARK: - JEAssert() variants

public func JEAssert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    #if DEBUG
        if !condition() {
            
            let messageString = message()
            JEDebugging.logFailureInAssertion(
                withMessage: messageString,
                location: JELogLocation(
                    fileName: (fileName as NSString).lastPathComponent,
                    functionName: functionName,
                    lineNumber: UInt32(lineNumber)))
            NSException.raise(
                NSExceptionName.internalInconsistencyException,
                format: "%@",
                arguments: getVaList([messageString]))
        }
    #endif
}

public func JEAssertMainThread(_ fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEAssert(
        Thread.isMainThread,
        "Code expected to run on the main thread",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertBackgroundThread(_ fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEAssert(
        !Thread.isMainThread,
        "Code expected to run on the main thread",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertMethodOverride(_ fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEAssert(
        false,
        "Required method \(functionName) override not implemented.",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}


// MARK: - JELog() variants

public func JELog(_ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JELogLevel(.trace, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogTrace(_ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JELogLevel(.trace, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogNotice(_ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JELogLevel(.notice, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogAlert(_ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JELogLevel(.alert, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogFatal(_ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JELogLevel(.fatal, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogLevel(_ level: JELogLevelMask, _ message: @autoclosure @escaping () -> String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDebugging.logLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        logMessage: { return message() })
}


// MARK: - JEDump() variants

public let _JEDumpDefaultLabel = "<No label>"

public func JEDump(_ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump(_ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump<T>(_ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(_ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(_ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace<T>(_ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(_ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(_ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice<T>(_ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(_ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(_ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert<T>(_ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(_ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(_ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal<T>(_ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDumpLevel(.fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpLevel(_ level: JELogLevelMask, _ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(NSStringFromClass(object_getClass(object)!))) \(object.loggingDescription())" })
}

public func JEDumpLevel(_ level: JELogLevelMask, _ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: {
            
            var description = "\(object)"
            if description.isEmpty {
                
                description = "<No logging description available>"
            }
            return "(\(String(reflecting: type(of: object))) \(description)"
        }
    )
}

public func JEDumpLevel<T>(_ level: JELogLevelMask, _ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(String(reflecting: type(of: object)))) \(object)" })
}
