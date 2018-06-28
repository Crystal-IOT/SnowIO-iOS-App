//
//  UITableViewExtension.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    func setupTableWhitBackground() {
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        
        let backgroundImage = UIImage(named: "background")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    func setupTable() {
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
    }
    
    func emptyTableApplyData() {
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    
    func hasValueTableApplyData() {
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        self.tableView?.reloadData()
    }
    
    func enabledScroll() {
        self.tableView.isScrollEnabled = true
    }
    
    func disabledScroll() {
        self.tableView.isScrollEnabled = false
    }
    
    // **
    // **  MARK : KEYBOARD GESTION
    // **
    func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
