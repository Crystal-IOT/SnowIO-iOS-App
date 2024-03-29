//
//  LoginViewController.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController, UserAuthenticationProtocol {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mPrefs = Preferences()
    var mAlert = AlertsManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Utils Variables
    var isExit = false
    
    // Outlets
    @IBOutlet weak var mUsername: UITextField!
    @IBOutlet weak var mPassword: UITextField!
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userAuthenticationProtocol = self
        mPrefs.setDefault()
        
        //let timeMillis = CLong(Date().timeIntervalSince1970 / 1000)
        //mPrefs.userTokenExpires! > timeMillis
        if (mPrefs.userEmail != "" && mPrefs.userToken != "") {
            self.view.performLogin()
        }
        
        // Setup Table and embedded views
        setupKeyboard()
        setupTableWhitBackground()
        enabledScroll()
        adjustLoading(loading: loadingView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isExit = true
    }
    

    // MARK : Crystal-IOT DataSource Methods
    func performBasicAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        self.view.performLogin()
    }
    
    func cancelBasicAction() {
        enabledScroll()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    // MARK : IBAction
    @IBAction func passwordResetAction(_ sender: Any) {
        performSegue(withIdentifier: "passwordResetSegue", sender: self)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        disabledScroll()
        
        if(!NetworkManager().isConnectedToNetwork()) {
            mAlert.showAlert(title: NSLocalizedString("txt_network", comment: ""), message: NSLocalizedString("txt_startNetwork", comment: ""))
        }
        else {
            showLoading(view: self.view, loading: loadingView)
            
            if(!mUsername.text!.isEmpty && !mPassword.text!.isEmpty) {
                mDatasourceManager.performLogin(email: mUsername.text!, password: mPassword.text!)
            }
            else {
                cancelBasicAction()
                mAlert.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("value_empty", comment: ""))
            }
        }
    }
    
    // MARK : SCROLL VIEW DELEGATE
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.isExit == false) {
            if (scrollView.contentOffset.y <= 0) {
                adjustLoading(loading: self.loadingView)
            } else {
                adjustLoadingOnScroll(loading: self.loadingView)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordResetSegue" {
            _ = segue.destination as? PasswordResetViewController
        }
    }
}
