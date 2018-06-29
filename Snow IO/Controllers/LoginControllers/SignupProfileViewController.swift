//
//  SignupProfileViewController.swift
//  Snow IO
//
//  Created by Steven F. on 05/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class SignupProfileViewController: UITableViewController, UserAuthenticationProtocol, UserProfilAuthenticationProtocol, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mAlert = AlertsManager()
    var mDataSourceManager = SnowIOFirebaseManager()
    var mProfile: Array<ProfileModel>!
    
    // Utils variable
    static var idProfil: Int?
    var userToCreate: UserModel?
    var userPassword: String?
    var isCreated = false
    var isExit = false
    
    // Outlets
    @IBOutlet weak var mPickerView: UIPickerView!
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(SignupProfileViewController.idProfil != nil) {
            mPickerView.selectRow(SignupProfileViewController.idProfil!, inComponent: 0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isExit = true
    }
    
    
    // MARK : CUSTOM Methods
    func setupView() {
        mDataSourceManager.userAuthenticationProtocol = self
        mDataSourceManager.userAuthenticationProfileProtocol = self
        
        mPickerView.delegate = self
        mPickerView.dataSource = self
        
        // Setup Table & embedded views
        setupKeyboard()
        setupTableWhitBackground()
        enabledScroll()
        
        adjustLoading(loading: loadingView)
        showLoading(view: self.view, loading: loadingView)
        
        mDataSourceManager.getAllUserProfile()
    }
   
    
    // MARK : Crystal-IOT DataSource Methods (Authentication protocol)
    func performBasicAction() {
        self.removeLoadingView(loadingView: self.loadingView, tableView: self.tableView)
        
        if(isCreated) {
            self.view.performLogin()
        } else {
            mDataSourceManager.performLogin(email: (userToCreate?.email)!, password: userPassword!)
            isCreated = true
        }
     }
    
    func cancelBasicAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    
    // MARK : Crystal-IOT DataSource Methods (GetProfile protocol)
    func performAction(profileList: Array<ProfileModel>) {
        mProfile = profileList
        
        self.mPickerView.reloadAllComponents()
        enabledScroll()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    func cancelAction() {
        emptyTableApplyData()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    
    // MARK : IBAction
    @IBAction func signupAction(_ sender: Any) {
        disabledScroll()
        showLoading(view: self.view, loading: loadingView)
        mDataSourceManager.performSignUp(user: self.userToCreate!, password: userPassword!)
    }
    
    
    // MARK : UIPickerView Delegate & DataSources Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(mProfile != nil) {
            return mProfile.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mProfile[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SignupProfileViewController.idProfil = row
        self.userToCreate?.idProfil =  SignupProfileViewController.idProfil
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
}
