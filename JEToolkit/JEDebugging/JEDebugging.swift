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

public func JEAssert(@autoclosure condition: () -> Bool, @autoclosure _ message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    #if DEBUG
        if !condition() {
            
            let messageString = message()
            JEDebugging.logFailureInAssertionWithMessage(
                messageString,
                location: JELogLocation(
                    fileName: (fileName as NSString).lastPathComponent,
                    functionName: functionName,
                    lineNumber: UInt32(lineNumber)))
            NSException.raise(
                NSInternalInconsistencyException,
                format: "%@",
                arguments: getVaList([messageString]))
        }
    #endif
}

public func JEAssertMainThread(fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEAssert(
        NSThread.isMainThread(),
        "Code expected to run on the main thread",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertBackgroundThread(fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEAssert(
        !NSThread.isMainThread(),
        "Code expected to run on the main thread",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertMethodOverride(fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEAssert(
        false,
        "Required method \(functionName) override not implemented.",
        fileName: (fileName as NSString).lastPathComponent,
        lineNumber: lineNumber,
        functionName: functionName)
}


// MARK: - JELog() variants

public func JELog(@autoclosure(escaping) message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogTrace(@autoclosure(escaping) message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogNotice(@autoclosure(escaping) message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JELogLevel(.Notice, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogAlert(@autoclosure(escaping) message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JELogLevel(.Alert, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogFatal(@autoclosure(escaping) message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JELogLevel(.Fatal, message, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JELogLevel(level: JELogLevelMask, @autoclosure(escaping) _ message: () -> String, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDebugging.logLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        logMessage: { return message() })
}


// MARK: - JEDump() variants

private let _JEDumpDefaultLabel = "<No label>"

public func JEDump(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: (fileName as NSString).lastPathComponent, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpLevel(level: JELogLevelMask, _ object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(NSStringFromClass(object_getClass(object)))) \(object.loggingDescription())" })
}

public func JEDumpLevel(level: JELogLevelMask, _ object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
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
            return "(\(String(reflecting: object.dynamicType)) \(description)"
        }
    )
}

public func JEDumpLevel<T>(level: JELogLevelMask, _ object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: Int = __LINE__, functionName: String = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: (fileName as NSString).lastPathComponent,
            functionName: functionName,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(String(reflecting: object.dynamicType))) \(object)" })
}
