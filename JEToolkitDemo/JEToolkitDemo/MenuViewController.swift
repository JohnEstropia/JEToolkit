//
//  MenuViewController.swift
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 10/13/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

import UIKit
import JEToolkit


enum MenuIndex: Int {
    
    case JELogExamples = 0
    case JEAssertExamples
    case JEDumpExamples
    
    static let count = JEDumpExamples.rawValue + 1
}


class MenuViewController: UITableViewController {

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return MenuIndex.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithClass(
            UITableViewCell.self,
            forIndexPath: indexPath) as UITableViewCell

        var text: String?
        var detail: String?
        if let menuIndex = MenuIndex(rawValue: indexPath.row) {
            
            switch menuIndex {
                
            case .JELogExamples:
                text = JEL10n("menuViewController.cellText.log")
                detail = JEL10n("menuViewController.cellDetail.log")
                
            case .JEAssertExamples:
                text = JEL10n("menuViewController.cellText.assert")
                detail = JEL10n("menuViewController.cellDetail.assert")
                
            case .JEDumpExamples:
                text = JEL10n("menuViewController.cellText.dump")
                detail = JEL10n("menuViewController.cellDetail.dump")
            }
        }
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detail
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let menuIndex = MenuIndex(rawValue: indexPath.row) {
            
            switch menuIndex {
                
            case .JELogExamples:
                self.performSegue(withIdentifier: JELogViewController.classNameInAppModule(), sender: nil)
                
            case .JEAssertExamples:
                self.performSegue(withIdentifier: JEAssertViewController.classNameInAppModule(), sender: nil)
                
            case .JEDumpExamples:
                self.performSegue(withIdentifier: JEDumpViewController.classNameInAppModule(), sender: nil)
            }
        }
    }

}
