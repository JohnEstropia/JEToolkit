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

public func JEAssert(condition: @autoclosure() -> Bool, message: @autoclosure() -> String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
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

public func JELog(message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogTrace(message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Trace, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogNotice(message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Notice, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogAlert(message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Alert, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogFatal(message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JELogLevel(.Fatal, message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JELogLevel(level: JELogLevelMask, message: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.logLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        format: "%@",
        arguments: getVaList([message]))
}


// MARK: - JEDump() variants

public func JEDump(object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump(object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDump<T>(object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace(object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpTrace<T>(object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Trace, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice(object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpNotice<T>(object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Notice, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert(object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpAlert<T>(object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Alert, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal(object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpFatal<T>(object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDumpLevel(.Fatal, object, label, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
}

public func JEDumpLevel(level: JELogLevelMask, object: NSObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: "(\(NSStringFromClass(object_getClass(object)))) \(object.loggingDescription())")
}

public func JEDumpLevel(level: JELogLevelMask, object: AnyObject, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    var description = "\(object)"
    if description.isEmpty {
        
        description = "<No logging description available>"
    }
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: "(\(_stdlib_getDemangledTypeName(object))) \(description)")
}

public func JEDumpLevel<T>(level: JELogLevelMask, object: T, label: String, fileName: String = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
    
    JEDebugging.dumpLevel(
        level,
        location: JELogLocation(
            fileName: fileName.lastPathComponent,
            functionName: functionName.stringValue,
            lineNumber: UInt32(lineNumber)),
        label: label,
        valueDescription: "(\(_stdlib_getDemangledTypeName(object))) \(object)")
}
