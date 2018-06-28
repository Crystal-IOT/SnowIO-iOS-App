//
//  MenuTableViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import KYDrawerController

class MenuTableViewController: UITableViewController, UserProfileProtocol {
    
    // Segue Identifiers
    let homeIdentifier = "homeSegue"
    let profileIdentifer = "profileSegue"
    let friendsIdentifier = "friendsSegue"
    let mapIdentifier = "mapSegue"
    let activitiesIdentifier = "activitiesSegue"
    
    // Timers & Others
    var isOneDisplay = true
    var networkTimer : Timer?
    static var headerTimer : Timer?
    
    // Utils variables
    static var isDisplaying: Bool = false
    
    // Managers
    var mPrefs = Preferences()
    var mDatasourceManager = SnowIOFirebaseManager.sharedInstance
    
    // Outlets
    @IBOutlet weak var usernameImage: imageCircleView!
    @IBOutlet weak var usernameName: UILabel!
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userProfileProtocol = self
        
        networkTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.checkNetwork), userInfo: nil, repeats: true)
        MenuTableViewController.initHeaderTimer()
        
        self.tableView.allowsSelection = false
        
        if(mDatasourceManager.mUser != nil) {
            updateUI()
        } else {
            getHeaderInformation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setCellValue(index: AppDelegate.currentPage)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.networkTimer?.invalidate()
        MenuTableViewController.stopHeaderTimer()
    }
    
    
    // MARK : - Static Custom Methods
    static func initHeaderTimer() {
        MenuTableViewController.headerTimer = Timer.scheduledTimer(timeInterval: 10.0, target: MenuTableViewController(),
                                                                   selector: #selector(MenuTableViewController().getHeaderInformation), userInfo: nil, repeats: true)
    }
    
    static func stopHeaderTimer() {
        MenuTableViewController.headerTimer?.invalidate()
    }
    
    
    // MARK : Selector Methods
    @objc func checkNetwork() {
        if(!NetworkManager().isConnectedToNetwork() && isOneDisplay) {
            AlertsManager().showNetworkAlert(message: NSLocalizedString("txt_missNetwork", comment: ""), view: self.view)
            isOneDisplay = false
        }
    }
    
    @objc func getHeaderInformation() {
        mDatasourceManager.getCurrentUserProfile(email: mPrefs.userEmail!)
    }
    
    // MARK : Delegate Methods
    func performAction(userAccount: UserModel, userProfile: ProfileModel) {
        mDatasourceManager.mUser = userAccount
        updateUI()
    }
    
    func performUpdateAction() {
        return
    }
    
    func cancelAction() {
        return
    }
    
    // MARK : CUSTOM METHODS
    func updateUI() {
        if(mDatasourceManager.mUser.picture != "nil") {
            usernameImage.image = PictureManager().decodeStringToImage(image: mDatasourceManager.mUser.picture)
        }
        usernameName.text = mDatasourceManager.mUser.firstname
        self.tableView.allowsSelection = true
    }
    
    func setCellValue(index: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: index)!
        selectedCell.contentView.backgroundColor = UIColor().colorFromHexaHalfAlpha(rgbValue: UIColor.applicationColor.whiteColor.rawValue)
    }
    
    
    // MARK : NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc: DrawerViewController = segue.destination as? DrawerViewController {
            
            if segue.identifier == homeIdentifier {
                vc.actionToPerform = homeIdentifier
            }
            
            if segue.identifier == profileIdentifer {
                vc.actionToPerform = profileIdentifer
            }
            
            if segue.identifier == friendsIdentifier {
                vc.actionToPerform = friendsIdentifier
            }
            
            if segue.identifier == mapIdentifier {
                vc.actionToPerform = mapIdentifier
            }
            
            if segue.identifier == activitiesIdentifier {
                vc.actionToPerform = activitiesIdentifier
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Menu
        if indexPath.section == 1 {
            
            // Home
            if indexPath.row == 0 {
                performSegue(withIdentifier: homeIdentifier, sender: self)
            }
            
            // Profile
            if indexPath.row == 1 {
                performSegue(withIdentifier: profileIdentifer, sender: self)
            }
            
            // Friends
            if indexPath.row == 2 {
                performSegue(withIdentifier: friendsIdentifier, sender: self)
            }
            
            // Map
            if indexPath.row == 3 {
                performSegue(withIdentifier: mapIdentifier, sender: self)
            }
            
            // Activities
            if indexPath.row == 4 {
                performSegue(withIdentifier: activitiesIdentifier, sender: self)
            }
            
            setCellValue(index: indexPath)
            AppDelegate.currentPage = IndexPath(row: indexPath.row, section: indexPath.section)
        }
        
        // Others
        if indexPath.section == 2 {
            
            // LogOut
            if indexPath.row == 0 {
                MenuTableViewController.stopHeaderTimer()
                self.view.performLogout()
            }
            
            setCellValue(index: indexPath)
            AppDelegate.currentPage = IndexPath(row: 0, section: 1)
        }
    }
}

