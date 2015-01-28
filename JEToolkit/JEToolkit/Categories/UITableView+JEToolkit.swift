//
//  UITableView+JEToolkit.swift
//  JEToolkit
//
//  Copyright (c) 2015 John Rommel Estropia
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

import UIKit

public extension UITableView {
    
    public func dequeueReusableCellWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, forIndexPath indexPath: NSIndexPath?) -> T {
        
        return self.dequeueReusableCellWithClass(
            tableViewCellClass as AnyClass!,
            forIndexPath: indexPath) as T
    }
    
    public func dequeueReusableCellWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, subIdentifier: String, forIndexPath indexPath: NSIndexPath?) -> T {
        
        return self.dequeueReusableCellWithClass(
            tableViewCellClass as AnyClass!,
            subIdentifier: subIdentifier,
            forIndexPath: indexPath) as T
    }
    
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(headerFooterViewClass: T.Type) -> T {
        
        return self.dequeueReusableHeaderFooterViewWithClass(
            headerFooterViewClass as AnyClass!) as T
    }
    
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(headerFooterViewClass: T.Type, subIdentifier: String) -> T {
        
        return self.dequeueReusableHeaderFooterViewWithClass(
            headerFooterViewClass as AnyClass!,
            subIdentifier: subIdentifier) as T
    }
    
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass!) as T
    }
    
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, subIdentifier: String) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass!,
            subIdentifier: subIdentifier) as T
    }
}