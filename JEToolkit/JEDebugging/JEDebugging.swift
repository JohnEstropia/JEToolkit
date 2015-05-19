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

public func JEAssert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    #if DEBUG
        if !condition() {
            
            let messageString = message()
            JEDebugging.logFailureInAssertionWithMessage(
                messageString,
                location: JELogLocation(
                    fileName: fileName.lastPathComponent,
                    functionName: functionName.stringValue,
                    lineNumber: UInt32(lineNumber)))
            NSException.raise(
                NSInternalInconsistencyException,
                format: "%@",
                arguments: getVaList([messageString]))
        }
    #endif
}

public func JEAssertMainThread(fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEAssert(
        NSThread.isMainThread(),
        "Code expected to run on the main thread",
        fileName: fileName,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertBackgroundThread(fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEAssert(
        !NSThread.isMainThread(),
        "Code expected to run on the main thread",
        fileName: fileName,
        lineNumber: lineNumber,
        functionName: functionName)
}

public func JEAssertMethodOverride(fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEAssert(
        false,
        "Required method \(functionName) override not implemented.",
        fileName: fileName,
        lineNumber: lineNumber,
        functionName: functionName)
}


// MARK: - JELog() variants

public func JELog(@autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogTrace(@autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogNotice(@autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Notice, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogAlert(@autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Alert, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogFatal(@autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Fatal, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogLevel(level: JELogLevelMask, @autoclosure message: () -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.logLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        logMessage: message)
}


// MARK: - JEDump() variants

private let _JEDumpDefaultLabel = "<No label>"

public func JEDump(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal<T>(object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpLevel(level: JELogLevelMask, object: NSObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(NSStringFromClass(object_getClass(object)))) \(object.loggingDescription())" })
}

public func JEDumpLevel(level: JELogLevelMask, object: AnyObject, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: {
            
            var description = "\(object)"
            if description.isEmpty {
                
                description = "<No logging description available>"
            }
            return "(\(_stdlib_getDemangledTypeName(object))) \(description)"
        }
    )
}

public func JEDumpLevel<T>(level: JELogLevelMask, object: T, _ label: String = _JEDumpDefaultLabel, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: { "(\(_stdlib_getDemangledTypeName(object))) \(object)" })
}
