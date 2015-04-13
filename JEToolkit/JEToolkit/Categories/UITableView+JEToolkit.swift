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
    
    /*! Dequeues a UITableViewCell from the receiver. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueReusableCellWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, forIndexPath indexPath: NSIndexPath?) -> T {
        
        return self.dequeueReusableCellWithClass(
            tableViewCellClass as AnyClass,
            forIndexPath: indexPath) as! T
    }
    
    /*! Dequeues a UITableViewCell from the receiver. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueReusableCellWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, subIdentifier: String, forIndexPath indexPath: NSIndexPath?) -> T {
        
        return self.dequeueReusableCellWithClass(
            tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            forIndexPath: indexPath) as! T
    }
    
    /*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
    @param headerFooterViewClass the UITableViewHeaderFooterView class name
    */
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(headerFooterViewClass: T.Type) -> T {
        
        return self.dequeueReusableHeaderFooterViewWithClass(
            headerFooterViewClass as AnyClass) as! T
    }
    
    /*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
    @param headerFooterViewClass the UITableViewHeaderFooterView class name
    @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
    */
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(headerFooterViewClass: T.Type, subIdentifier: String) -> T {
        
        return self.dequeueReusableHeaderFooterViewWithClass(
            headerFooterViewClass as AnyClass,
            subIdentifier: subIdentifier) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    */
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: nil) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    @param setupBlock a block to perform before the cell calls -layoutIfNeeded
    */
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, setupBlock: ((cell: T) -> Void)?) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: { cell in
                
                setupBlock?(cell: cell as! T)
            }
        ) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
    */
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, subIdentifier: String) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: nil) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
    @param tableViewCellClass the UITableViewCell class name
    @param setupBlock a block to perform before the cell calls -layoutIfNeeded
    */
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(tableViewCellClass: T.Type, subIdentifier: String, setupBlock: ((cell: T) -> Void)?) -> T {
        
        return self.cellForQueryingHeightWithClass(
            tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: { cell in
                
                setupBlock?(cell: cell as! T)
            }
        ) as! T
    }
}