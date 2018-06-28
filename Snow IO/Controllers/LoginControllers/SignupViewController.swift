//
//  SignupViewController.swift
//  Snow IO
//
//  Created by Steven F. on 05/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class SignupViewController: UITableViewController {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mAlert = AlertsManager()
    
    // Utils variable
    var user: UserModel?
    
    // Outlets
    @IBOutlet weak var mFirstName: UITextField!
    @IBOutlet weak var mLastName: UITextField!
    @IBOutlet weak var mPhone: UITextField!
    @IBOutlet weak var mEmail: UITextField!
    @IBOutlet weak var mPassword: UITextField!
    @IBOutlet weak var mConfirmPassword: UITextField!

    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup Table & embedded views
        setupKeyboard()
        setupTableWhitBackground()
        enabledScroll()
        adjustLoading(loading: loadingView)
    }
    
    func cancelBasicAction() {
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
    }
    
    // MARK : IBAction
    @IBAction func signupAction(_ sender: Any) {
        if(!NetworkManager().isConnectedToNetwork()) {
            mAlert.showAlert(title: NSLocalizedString("txt_network", comment: ""), message: NSLocalizedString("txt_startNetwork", comment: ""))
        }
        else {
            showLoading(view: self.view, loading: loadingView)
            
            if (!mFirstName.text!.isEmpty && !mLastName.text!.isEmpty && !mEmail.text!.isEmpty && !mPassword.text!.isEmpty && !mConfirmPassword.text!.isEmpty) {
                
                if(mPassword.text! == mConfirmPassword.text!) {
                    
                    let userPosition = PositionModel.init(latitude: 0, longitude: 0)
                    
                    self.user = UserModel.init(idProfil: 0, email: mEmail.text!,
                                              firstname: mFirstName.text!, lastname: mLastName.text!,
                                              phone: mPhone.text!, picture: "nil", position: userPosition)
                    
                    cancelBasicAction()
                    performSegue(withIdentifier: "continueSignUpSegue", sender: self)
                } else {
                    cancelBasicAction()
                    mAlert.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("pasword_not_match", comment: ""))
                }
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
        if (scrollView.contentOffset.y <= 0) {
            adjustLoading(loading: self.loadingView)
        } else {
            adjustLoadingOnScroll(loading: self.loadingView)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "continueSignUpSegue" {
            
            let SignUpProfileScreen = segue.destination as? SignupProfileViewController
            SignUpProfileScreen?.userToCreate = self.user
            SignUpProfileScreen?.userPassword = self.mPassword.text
            
            if(SignupProfileViewController.idProfil != nil) {
                self.user?.idProfil = SignupProfileViewController.idProfil
            }
        }
    }
}
