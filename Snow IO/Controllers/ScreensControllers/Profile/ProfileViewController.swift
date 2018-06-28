//
//  ProfileViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import Toaster

class ProfileViewController: UITableViewController, UITextFieldDelegate, UserProfileProtocol, pullRefreshProtocol, mainDoubleBackScreenProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BackScreen Protocol
    typealias previousScreenOne = ProfileChooseViewController
    typealias previousScreenTwo = PasswordChooseViewController
    
    
    // Managers
    var mAlertManager = AlertsManager()
    var mPrefs = Preferences()
    
    var mDatasourceManager = SnowIOFirebaseManager()
    var mUser: UserModel!
    
    var mLastProfile: ProfileModel!
    var mProfile: ProfileModel!
    var mProfileEditing: Bool = false
    
    // Segue Variables
    var userIsEditing = false
    let profileChooseSegue = "profileChooseSegue"
    let passwordChooseSegue = "passwordChooseSegue"
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userProfileProtocol = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if(previousScreenOne.isBacked == true) {
            mDatasourceManager.userProfileProtocol = self
            
            previousScreenOne.isBacked = false
            
            mProfile.name = previousScreenOne.currentProfileName
            mLastProfile = ProfileModel.init(name: previousScreenOne.lastProfileName)
            
            if(mProfile.name != mLastProfile.name) { 
                mProfileEditing = true
                self.tableView.reloadData()
            } else {
                mProfileEditing = false
            }
            
            mUser.idProfil = previousScreenOne.currentProfileIndex
            
            self.tableView.reloadData()
        }
        
        if (previousScreenTwo.isBacked == true) {
            mDatasourceManager.userProfileProtocol = self
            
            previousScreenTwo.isBacked = false
            
            self.tableView.reloadData()
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(DrawerViewController.isOpen == false && profileHeader.isEditing == false && userIsEditing == false) {
            resetView()
        }
    }
    
    // MARK : IBACTIONS
    @IBAction func menuBtn(_ sender: Any) {
        if let drawerController = navigationController?.parent as? DrawerViewController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func moreBtn(_ sender: Any) {
        mAlertManager.showAboutActions()
    }
    
    // MARK : Custom Method
    func setupView() {
        // Setup Table & embedded views
        setupTable()
        setupPullRefresh()
        adjustLoading(loading: loadingView)
        showLoading(view: self.view, loading: loadingView)
        
        mDatasourceManager.getCurrentUserProfile(email: mPrefs.userEmail!)
    }
    
    func resetView() {
        if(mUser != nil  && mProfile != nil) {
            mUser = nil
            mProfile = nil
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    @objc func updateUserProfile() {
        for section in 1 ..< 2 {
            for row in 0 ..< self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                
                if(indexPath.row != 3 && indexPath.row != 5) {
                    let cell = tableView.cellForRow(at: indexPath) as! profileSimpleInformations
                    
                    if indexPath.row == 0 { mUser.firstname = cell.informationValue.text }
                    if indexPath.row == 1 { mUser.lastname = cell.informationValue.text }
                    if indexPath.row == 2 { mUser.email = cell.informationValue.text }
                    if indexPath.row == 4 { mUser.phone = cell.informationValue.text }
                }
            }
        }
        mDatasourceManager.setCurrentUserProfile(userToUpdate: mUser)
        showLoading(view: self.view, loading: loadingView)
        resetView()
    }
    
    
    // MARK : - Crystal-IOT DataSource Methods
    func performAction(userAccount: UserModel, userProfile: ProfileModel) {
        mUser = userAccount
        mProfile = userProfile
        
        if(mUser != nil && mProfile != nil) {
            emptyTableApplyData()
        } else {
            emptyTableApplyData()
            showEmptyMessage(localizedKeyString: "empty_list")
        }
        
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        endRefresh()
    }
    
    func performUpdateAction() {
        Toast(text: NSLocalizedString("account_updated", comment: "") , delay: Delay.short, duration: Delay.long).show()
        mDatasourceManager.getCurrentUserProfile(email: mPrefs.userEmail!)
    }
    
    func cancelAction() {
        emptyTableApplyData()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        endRefresh()
    }
    
    
    // MARK : Pull To Refresh DataSource Methods
    func reloadData() {
        showLoading(view: self.view, loading: loadingView)
        resetView()
        mDatasourceManager.getCurrentUserProfile(email: mPrefs.userEmail!)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mUser != nil && mProfile != nil) {
            if(section == 0) {
                return 1
            } else if (section == 1) {
                return 6
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return 110
        } else if (indexPath.section == 1) {
            return UITableViewAutomaticDimension
        } else {
            return 65
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            if (indexPath.row == 3) {
                self.performSegue(withIdentifier: self.passwordChooseSegue, sender: self)
                self.userIsEditing = true
            }
            if(indexPath.row == 5) {
                self.performSegue(withIdentifier: self.profileChooseSegue, sender: self)
                self.userIsEditing = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileHeader", for: indexPath) as? profileHeader
            
            if(mUser.picture != "nil") {
                cell?.profileImage.image = PictureManager().decodeStringToImage(image: mUser.picture)
            }
            
            cell?.profileName.text = mUser.firstname + " " + mUser.lastname
            
            return cell!
        } else if (indexPath.section == 1) {
            
            let cellInformations = tableView.dequeueReusableCell(withIdentifier: "profileSimpleInformations", for: indexPath) as? profileSimpleInformations
            let cellChoose = tableView.dequeueReusableCell(withIdentifier: "profileChooseInformations", for: indexPath) as? profileChooseInformations
            
            if(indexPath.row == 0) {
                cellInformations?.informationName.text = NSLocalizedString("account_firstname", comment: "")
                cellInformations?.informationValue.placeholder = NSLocalizedString("account_firstname", comment: "")
                cellInformations?.informationValue.text = mUser.firstname
                cellInformations?.informationValue.delegate = self
                return cellInformations!
            }
            
            if(indexPath.row == 1) {
                cellInformations?.informationName.text = NSLocalizedString("account_lastname", comment: "")
                cellInformations?.informationValue.placeholder = NSLocalizedString("account_lastname", comment: "")
                cellInformations?.informationValue.text = mUser.lastname
                cellInformations?.informationValue.delegate = self
                return cellInformations!
            }
            
            if(indexPath.row == 2) {
                cellInformations?.informationName.text = NSLocalizedString("account_email", comment: "")
                cellInformations?.informationValue.placeholder = NSLocalizedString("account_email", comment: "")
                cellInformations?.informationValue.text = mUser.email
                cellInformations?.informationValue.delegate = self
                return cellInformations!
            }
            
            if(indexPath.row == 3) {
                
                let passwordCount = mPrefs.userPassword?.count
                var userPassword = ""
                for _ in 0..<passwordCount! {
                    userPassword += "•"
                }
                
                cellChoose?.informationName.text = NSLocalizedString("account_password", comment: "")
                cellChoose?.informationValue.text = userPassword
                return cellChoose!
            }
            
            if(indexPath.row == 4) {
                cellInformations?.informationName.text = NSLocalizedString("account_tel", comment: "")
                cellInformations?.informationValue.placeholder = NSLocalizedString("account_tel", comment: "")
                cellInformations?.informationValue.text = mUser.phone
                cellInformations?.informationValue.delegate = self
                return cellInformations!
            }
            
            if(indexPath.row == 5) {
                cellChoose?.informationName.text = NSLocalizedString("account_profile", comment: "")
                cellChoose?.informationValue.text = mProfile.name
                return cellChoose!
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileSave", for: indexPath) as? profileSave
            
            cell?.btnSave.setTitle(NSLocalizedString("btn_save", comment: ""), for: .normal)
            cell?.btnSave.addTarget(self, action: #selector(self.updateUserProfile), for: .touchUpInside)
            
            if self.mProfileEditing {
                cell?.btnSave?.enabledButton()
            } else {
                cell?.btnSave?.disableButton()
            }
            
            return cell!
        }
        return UITableViewCell()
    }
    
    
    // MARK : - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == self.profileChooseSegue {
            _ = segue.destination as? ProfileChooseViewController
            ProfileChooseViewController.currentProfileName = self.mProfile.name
        }
        
        if segue.identifier == self.passwordChooseSegue {
            _ = segue.destination as? PasswordChooseViewController
        }
    }
}

extension ProfileViewController {
    
    // MARK : - UITextField Delegate & Datasources methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var userInformations = Array<String>()
        var userchange = Array<Bool>()
        
        for section in 1 ..< 2 {
            for row in 0 ..< self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                
                if(indexPath.row != 3 && indexPath.row != 5) {
                    let cell = tableView.cellForRow(at: indexPath) as! profileSimpleInformations
                    userInformations.append(cell.informationValue.text!)
                }
            }
        }
        
        let btnIndexPath = IndexPath(row: 0, section: 2)
        self.tableView.scrollToRow(at: btnIndexPath, at: .top, animated: false)
        let saveCell = self.tableView.cellForRow(at: btnIndexPath) as! profileSave
        
        if mUser.firstname != userInformations[0] {
            userchange.append(true)
        } else {
            userchange.append(false)
        }
        
        if mUser.lastname != userInformations[1] {
            userchange.append(true)
        } else {
            userchange.append(false)
        }
        
        if mUser.email != userInformations[2] {
            userchange.append(true)
        } else {
            userchange.append(false)
        }
        
        if mUser.phone != userInformations[3] {
            userchange.append(true)
        } else {
            userchange.append(false)
        }
        
        var enabledButton = false
        for (index, element) in userInformations.enumerated() {
            if(userchange[index] && element != "") {
                enabledButton = true
            }
        }
        
        if (enabledButton || self.mProfileEditing) {
            saveCell.btnSave.enabledButton()
        } else {
            saveCell.btnSave.disableButton()
        }
    }
    
}

class profileHeader : UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    // Managers
    let imagePicker = UIImagePickerController()
    
    var mPrefs = Preferences()
    var mAlertManager = AlertsManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Utils
    static var isEditing: Bool = false
    
    override func awakeFromNib() {
        profileHeader.isEditing = false
        imagePicker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.choosePicture))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
    }
    
    @objc func choosePicture() {
        profileHeader.isEditing = true
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        let topController = mAlertManager.currentTopViewController()
        topController.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.contentMode = .scaleToFill
            profileImage.image = pickedImage
        }
        
        mDatasourceManager.setCurrentUserPicture(picture: PictureManager().encodeImageToBase64String(image: profileImage.image!), userMail: mPrefs.userEmail!)
        
        let topController = mAlertManager.currentTopViewController()
        topController.dismiss(animated: true, completion: nil)
        
        profileHeader.isEditing = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let topController = mAlertManager.currentTopViewController()
        topController.dismiss(animated: true, completion: nil)
        
        profileHeader.isEditing = false
    }
}

class profileSimpleInformations: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var informationName: UILabel!
    @IBOutlet weak var informationValue: UITextField!
    
    override func awakeFromNib() {
        informationValue.delegate = self
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        informationValue.resignFirstResponder()
        return true
    }
}

class profileChooseInformations: UITableViewCell {
    @IBOutlet weak var informationName: UILabel!
    @IBOutlet weak var informationValue: UILabel!
}

class profileSave: UITableViewCell {
    @IBOutlet weak var btnSave: actionButtons!
}

