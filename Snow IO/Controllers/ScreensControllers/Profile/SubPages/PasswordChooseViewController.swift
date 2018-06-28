//
//  PasswordChooseViewController.swift
//  Snow IO
//
//  Created by Steven F. on 13/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import Toaster

class PasswordChooseViewController: UITableViewController, UITextFieldDelegate, UserProfileProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BackScreen Protocol
    internal typealias `Self` = PasswordChooseViewController
    static var isBacked: Bool = false
    
    // Managers
    var mAlert = AlertsManager()
    var mPrefs = Preferences()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Utils Variables
    var isExit = false

    // MARK : - APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userProfileProtocol = self
        
        if(Self.isBacked) {
            Self.isBacked = false
        }
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isExit = true
        
        if(self.isMovingFromParentViewController) {
            Self.isBacked = true
        }
    }
    
    
    // MARK : - Custom Method
    func setupView() {
        setupKeyboard()
        setupTable()
        enabledScroll()
        adjustLoading(loading: loadingView)
        
        self.view.endEditing(false)
    }
    
    @objc func updateUserPassword() {
        showLoading(view: self.view, loading: loadingView)
        
        // Last Password
        let currentCellPath = IndexPath(row: 0, section: 0)
        let currentPassword = tableView.cellForRow(at: currentCellPath) as! profileSimpleInformations
        
        // New Password
        let newCellPath = IndexPath(row: 1, section: 0)
        let newPassword = tableView.cellForRow(at: newCellPath) as! profileSimpleInformations
        
        // New Password
        let newCellConfirmPath = IndexPath(row: 2, section: 0)
        let newPasswordConfirm = tableView.cellForRow(at: newCellConfirmPath) as! profileSimpleInformations
        
        if(currentPassword.informationValue.text! == mPrefs.userPassword) {
            
            if(newPassword.informationValue.text! == newPasswordConfirm.informationValue.text!) {
                mDatasourceManager.performUpdatePassword(password: newPassword.informationValue.text!)
            } else {
                cancelAction()
                mAlert.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("pasword_not_match", comment: ""))
            }
        } else {
            cancelAction()
            mAlert.showAlert(
                title: NSLocalizedString("error", comment: ""),
                message: NSLocalizedString("old_password_not_match", comment: ""))
        }
    }

    
    // MARK : - Crystal-IOT DataSource Methods
    func performAction(userAccount: UserModel, userProfile: ProfileModel) {
        return
    }
    
    func performUpdateAction() {
        Toast(text: NSLocalizedString("password_change", comment: "") , delay: Delay.short, duration: Delay.long).show()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    func cancelAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
   
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row != 3) {
            return UITableViewAutomaticDimension
        } else {
            return 65
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row != 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileSimpleInformations", for: indexPath) as? profileSimpleInformations
            
            if indexPath.row == 0 {
                cell?.informationName.text = NSLocalizedString("current_password", comment: "")
            } else if indexPath.row == 1 {
                cell?.informationName.text = NSLocalizedString("new_password", comment: "")
            } else {
                cell?.informationName.text = NSLocalizedString("confirm_new_password", comment: "")
            }
            
            cell?.informationValue.placeholder = NSLocalizedString("placeholder_password", comment: "")
            cell?.informationValue.isSecureTextEntry = true
            cell?.informationValue.delegate = self
            
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileSave", for: indexPath) as? profileSave
            
            cell?.btnSave.setTitle(NSLocalizedString("btn_change_password", comment: ""), for: .normal)
            cell?.btnSave.addTarget(self, action: #selector(self.updateUserPassword), for: .touchUpInside)
            cell?.btnSave.disableButton()
            
            return cell!
        }
    }
    
    
    // MARK : - UITextField Delegate & Datasources methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Last Password
        let currentCellPath = IndexPath(row: 0, section: 0)
        let currentPassword = tableView.cellForRow(at: currentCellPath) as! profileSimpleInformations
        
        // New Password
        let newCellPath = IndexPath(row: 1, section: 0)
        let newPassword = tableView.cellForRow(at: newCellPath) as! profileSimpleInformations
        
        // New Password
        let newCellConfirmPath = IndexPath(row: 2, section: 0)
        let newPasswordConfirm = tableView.cellForRow(at: newCellConfirmPath) as! profileSimpleInformations
        
        // Save Button
        let saveCellPath = IndexPath(row: 3, section: 0)
        let saveCell = tableView.cellForRow(at: saveCellPath) as! profileSave
        
        if((currentPassword.informationValue.text?.isEmpty)! == false && (newPassword.informationValue.text?.isEmpty)! == false && (newPasswordConfirm.informationValue.text?.isEmpty)! == false) {
            saveCell.btnSave.enabledButton()
        } else {
            saveCell.btnSave.disableButton()
        }
    }
    
    
    // MARK : - ScrollView Delegate & Datasources methods
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
