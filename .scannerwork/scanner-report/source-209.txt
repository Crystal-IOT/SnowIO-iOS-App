//
//  PullRefreshExtension.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

@objc protocol pullRefreshProtocol {
    func reloadData()
}

extension UITableViewController {
    
    // MARK : Pull-to-Refresh
    func setupPullRefresh() {
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.tintColor = UIColor.white
            tableView.refreshControl?.addTarget(self, action: #selector(pullRefreshProtocol.reloadData), for: .valueChanged)
        }
        else {
            tableView.addSubview(refreshControl!)
            refreshControl?.tintColor = UIColor.white
            refreshControl?.addTarget(self, action: #selector(pullRefreshProtocol.reloadData), for: .valueChanged)
        }
    }
    
    func endRefresh() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

extension UICollectionViewController {
    
    // MARK : Pull-to-Refresh
    func setupPullRefresh() {
        
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = UIRefreshControl()
            collectionView?.refreshControl?.tintColor = UIColor.white
            collectionView?.refreshControl?.addTarget(self, action: #selector(pullRefreshProtocol.reloadData), for: .valueChanged)
        }
        else {
            let refreshControl = UIRefreshControl()
            collectionView?.addSubview(refreshControl)
            refreshControl.tintColor = UIColor.white
            refreshControl.addTarget(self, action: #selector(pullRefreshProtocol.reloadData), for: .valueChanged)
        }
    }
    
    func endRefresh() {
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl?.endRefreshing()
        } else {
            UIRefreshControl().endRefreshing()
        }
    }
}
