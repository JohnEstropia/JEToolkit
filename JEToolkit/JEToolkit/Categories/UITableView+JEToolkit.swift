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
    public func dequeueCell<T: UITableViewCell>(as tableViewCellClass: T.Type, for indexPath: IndexPath?) -> T {
        
        return self.dequeueReusableCell(
            with: tableViewCellClass as AnyClass,
            for: indexPath) as! T
    }
    
    /*! Dequeues a UITableViewCell from the receiver. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
     @param indexPath the index path for the cell to dequeue
     */
    public func dequeueCell<T: UITableViewCell>(as tableViewCellClass: T.Type, subIdentifier: String, for indexPath: IndexPath?) -> T {
        
        return self.dequeueReusableCell(
            with: tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            for: indexPath) as! T
    }
    
    /*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
     @param headerFooterViewClass the UITableViewHeaderFooterView class name
     */
    public func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(as headerFooterViewClass: T.Type) -> T {
        
        return self.dequeueReusableHeaderFooterView(
            with: headerFooterViewClass as AnyClass) as! T
    }
    
    /*! Dequeues a UITableViewHeaderFooterView from the receiver. Requires the UITableViewHeaderFooterView nib file and reuseIdentifier to both be set to the class name.
     @param headerFooterViewClass the UITableViewHeaderFooterView class name
     @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
     */
    public func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(as headerFooterViewClass: T.Type, subIdentifier: String) -> T {
        
        return self.dequeueReusableHeaderFooterView(
            with: headerFooterViewClass as AnyClass,
            subIdentifier: subIdentifier) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     */
    public func cellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type) -> T {
        
        return self.cellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: nil) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param setup a block to perform before the cell calls -layoutIfNeeded
     */
    public func cellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, setup: ((_ cell: T) -> Void)?) -> T {
        
        return self.cellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: { cell in
                
                setup?(cell as! T)
            }
            ) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
     */
    public func cellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, subIdentifier: String) -> T {
        
        return self.cellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: nil) as! T
    }
    
    /*! Returns a shared UITableViewCell instance of the specified type. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param setup a block to perform before the cell calls -layoutIfNeeded
     */
    public func cellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, subIdentifier: String, setup: ((_ cell: T) -> Void)?) -> T {
        
        return self.cellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: { cell in
                
                setup?(cell as! T)
            }
            ) as! T
    }
    
    /*! Returns a static UITableViewCell instance of the specified type that is shared among all tableVIew instances. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     */
    public func staticCellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type) -> T {
        
        return self.staticCellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: nil) as! T
    }
    
    /*! Returns a static UITableViewCell instance of the specified type that is shared among all tableVIew instances. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param setup a block to perform before the cell calls -layoutIfNeeded
     */
    public func staticCellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, setup: ((_ cell: T) -> Void)?) -> T {
        
        return self.staticCellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: nil,
            setupBlock: { cell in
                
                setup?(cell as! T)
            }
        ) as! T
    }
    
    /*! Returns a static UITableViewCell instance of the specified type that is shared among all tableVIew instances. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param subIdentifier a suffix for the reuseIdentifier appended to the UITableViewCell class name.
     */
    public func staticCellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, subIdentifier: String) -> T {
        
        return self.staticCellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: nil) as! T
    }
    
    /*! Returns a static UITableViewCell instance of the specified type that is shared among all tableVIew instances. Typically called from -tableView:heightForRowAtIndexPath: to compute cell height with -sizeThatFits: or -systemLayoutSizeFittingSize:. Requires the UITableViewCell nib file and reuseIdentifier to both be set to the class name.
     @param tableViewCellClass the UITableViewCell class name
     @param setup a block to perform before the cell calls -layoutIfNeeded
     */
    public func staticCellForQueryingHeight<T: UITableViewCell>(as tableViewCellClass: T.Type, subIdentifier: String, setup: ((_ cell: T) -> Void)?) -> T {
        
        return self.staticCellForQueryingHeight(
            with: tableViewCellClass as AnyClass,
            subIdentifier: subIdentifier,
            setupBlock: { cell in
                
                setup?(cell as! T)
            }
        ) as! T
    }
    
    
    // MARK: Deprecated
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueCell(as:for:)")
    public func dequeueReusableCellWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type, forIndexPath indexPath: IndexPath?) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueCell(as:subIdentifier:for:)")
    public func dequeueReusableCellWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type, subIdentifier: String, forIndexPath indexPath: IndexPath?) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueHeaderFooterView(as:)")
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(_ headerFooterViewClass: T.Type) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueHeaderFooterView(as:subIdentifier:)")
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(_ headerFooterViewClass: T.Type, subIdentifier: String) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "cellForQueryingHeight(as:)")
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "cellForQueryingHeight(as:setup:)")
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type, setupBlock: ((_ cell: T) -> Void)?) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "cellForQueryingHeight(as:subIdentifier:)")
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type, subIdentifier: String) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "cellForQueryingHeight(as:subIdentifier:setup:)")
    public func cellForQueryingHeightWithClass<T: UITableViewCell>(_ tableViewCellClass: T.Type, subIdentifier: String, setupBlock: ((_ cell: T) -> Void)?) -> T {
        
        fatalError()
    }
}
