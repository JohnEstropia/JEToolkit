//
//  UICollectionView+JEToolkit.swift
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

public extension UICollectionView {
    
    /*! Dequeues a UICollectionViewCell from the receiver. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
    @param collectionViewCellClass the UICollectionViewCell class name
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueCell<T: UICollectionViewCell>(as collectionViewClass: T.Type, for indexPath: IndexPath) -> T {
        
        return self.dequeueReusableCell(
            with: collectionViewClass as AnyClass,
            for: indexPath) as! T
    }
    
    /*! Dequeues a UICollectionViewCell from the receiver. Requires the UICollectionViewCell nib file and reuseIdentifier to both be set to the class name.
    @param collectionViewCellClass the UICollectionViewCell class name
    @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionViewCell class name.
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueCell<T: UICollectionViewCell>(as collectionViewClass: T.Type, subIdentifier: String, for indexPath: IndexPath) -> T {
        
        return self.dequeueReusableCell(
            with: collectionViewClass as AnyClass,
            subIdentifier: subIdentifier,
            for: indexPath) as! T
    }
    
    /*! Dequeues a UICollectionReusableView from the receiver. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
    @param supplementaryViewClass the UICollectionReusableView class name
    @param supplementaryViewKind the UICollectionReusableView kind string
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueSupplementaryView<T: UICollectionReusableView>(as supplementaryViewClass: T.Type, ofKind supplementaryViewKind: String, for indexPath: IndexPath) -> T {
        
        return self.dequeueSupplementaryView(
            with: supplementaryViewClass as AnyClass,
            ofKind: supplementaryViewKind,
            for: indexPath) as! T
    }
    
    /*! Dequeues a UICollectionReusableView from the receiver. Requires the UICollectionReusableView nib file and reuseIdentifier to both be set to the class name.
    @param supplementaryViewClass the UICollectionReusableView class name
    @param supplementaryViewKind the UICollectionReusableView kind string
    @param subIdentifier a suffix for the reuseIdentifier appended to the UICollectionReusableView class name.
    @param indexPath the index path for the cell to dequeue
    */
    public func dequeueSupplementaryView<T: UICollectionReusableView>(as supplementaryViewClass: T.Type, ofKind supplementaryViewKind: String, subIdentifier: String, for indexPath: IndexPath) -> T {
        
        return self.dequeueSupplementaryView(
            with: supplementaryViewClass as AnyClass,
            ofKind: supplementaryViewKind,
            subIdentifier: subIdentifier,
            for: indexPath) as! T
    }
        
        
    // MARK: Deprecated
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueCell(as:for:)")
    public func dequeueReusableCellWithClass<T: UICollectionViewCell>(_ collectionViewClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueCell(as:subIdentifier:for:)")
    public func dequeueReusableCellWithClass<T: UICollectionViewCell>(_ collectionViewClass: T.Type, subIdentifier: String, forIndexPath indexPath: IndexPath) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueSupplementaryView(as:ofKind:for:)")
    public func dequeueSupplementaryViewWithClass<T: UICollectionReusableView>(_ supplementaryViewClass: T.Type, ofKind supplementaryViewKind: String, forIndexPath indexPath: IndexPath) -> T {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.2.0, renamed: "dequeueSupplementaryView(as:ofKind:subIdentifier:for:)")
    public func dequeueSupplementaryViewWithClass<T: UICollectionReusableView>(_ supplementaryViewClass: T.Type, ofKind supplementaryViewKind: String, subIdentifier: String, forIndexPath indexPath: IndexPath) -> T {
        
        fatalError()
    }
}
