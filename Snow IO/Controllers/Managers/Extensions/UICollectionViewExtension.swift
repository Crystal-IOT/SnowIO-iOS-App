//
//  UICollectionViewExtension.swift
//  Snow IO
//
//  Created by Steven F. on 04/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UICollectionViewController {
    
    func setupTableWhitBackground() {
        self.collectionView?.isScrollEnabled = false
        
        let backgroundImage = UIImage(named: "background")
        let imageView = UIImageView(image: backgroundImage)
        self.collectionView?.backgroundView = imageView
    }
    
    func setupTable() {
        self.collectionView?.isScrollEnabled = false
    }
    
    func emptyTableApplyData() {
        //self.tableView.isUserInteractionEnabled = false
        self.collectionView?.isScrollEnabled = false
        self.collectionView?.reloadData()
    }
    
    func hasValueTableApplyData() {
        self.collectionView?.isScrollEnabled = true
        self.collectionView?.reloadData()
    }
    
    func enabledScroll() {
        self.collectionView?.isScrollEnabled = true
    }
    
    func disabledScroll() {
        self.collectionView?.isScrollEnabled = false
    }
}
