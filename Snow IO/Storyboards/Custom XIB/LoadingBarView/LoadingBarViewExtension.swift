
//
//  ViewControllerExtension.swift
//  CloudWeather
//
//  Created by Steven F. on 24/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK : Adjust loading frame XIB
    func adjustLoading(loading : LoadingBarView) {
        loading.mView.frame = CGRect(x: 0,
                                     y: -(self.navigationController?.navigationBar.frame.size.height)!,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)
    }
    
    func adjustLoadingFromZero(loading : LoadingBarView) {
        loading.mView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)
    }
    
    // MARK : Adjust loading frame XIB on Scroll
    func adjustLoadingOnScroll(loading : LoadingBarView) {
        loading.mView.frame = CGRect(x: 0,
                                     y: view.safeAreaInsets.top,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)
    }
    
    func showLoading(view : UIView, loading: LoadingBarView) {
        view.addSubview(loading.mView)
        loading.mLoading.startAnimating()
    }
    
    func removeLoadingView(loadingView : LoadingBarView, tableView : UITableView) {
        tableView.isScrollEnabled = true
        loadingView.mLoading.stopAnimating()
        loadingView.mView.removeFromSuperview()
    }
    
    func removeLoadingView(loadingView : LoadingBarView) {
        loadingView.mLoading.stopAnimating()
        loadingView.mView.removeFromSuperview()
    }

}
