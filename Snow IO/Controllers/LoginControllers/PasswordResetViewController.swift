//
//  PasswordResetViewController.swift
//  Snow IO
//
//  Created by Steven F. on 05/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class PasswordResetViewController: UITableViewController, UserAuthenticationProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mPrefs = Preferences()
    var mAlert = AlertsManager()
    
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Outlets
    @IBOutlet weak var mEmail: UITextField!
   
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userAuthenticationProtocol = self
        
        // Setup Table and embedded views
        setupKeyboard()
        setupTableWhitBackground()
        enabledScroll()
        adjustLoading(loading: loadingView)
    }
    
    func performBasicAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        mEmail.text = ""
        mAlert.showAlert(title: "title_passwordReset", message: "txt_passwordReset")
    }
    
    func cancelBasicAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    // MARK : IBAction
    @IBAction func passwordResetAction(_ sender: Any) {
        if(!NetworkManager().isConnectedToNetwork()) {
            mAlert.showAlert(title: NSLocalizedString("txt_network", comment: ""), message: NSLocalizedString("txt_startNetwork", comment: ""))
        }
        else
        {
            showLoading(view: self.view, loading: loadingView)
            
            if(!mEmail.text!.isEmpty) {
                mDatasourceManager.performPasswordReset(email: mEmail.text!)
            } else {
                cancelBasicAction()
                mAlert.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("value_empty", comment: ""))
            }
        }
    }
        
    // MARK : SCROLL VIEW DELEGATE
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            adjustLoading(loading: self.loadingView)
        } else {
            adjustLoadingOnScroll(loading: self.loadingView)
        }
    }
}
