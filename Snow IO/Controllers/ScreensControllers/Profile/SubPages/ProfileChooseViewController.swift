//
//  ProfileChooseViewController.swift
//  Snow IO
//
//  Created by Steven F. on 10/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class ProfileChooseViewController: UITableViewController, UserProfilAuthenticationProtocol, screenToBackProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BackScreen Protocol
    internal typealias `Self` = ProfileChooseViewController
    static var isBacked: Bool = false
    
    static var currentProfileIndex: Int = 0
    static var currentProfileName: String = ""
    static var lastProfileName: String = ""
    
    // Managers
    var mAlertManager = AlertsManager()
    var mPrefs = Preferences()
    
    var mDatasourceManager = SnowIOFirebaseManager()
    var mProfileList: Array<ProfileModel>!
    

    // MARK : - APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userAuthenticationProfileProtocol = self
        
        if(Self.isBacked) {
            Self.isBacked = false
        }
        
        ProfileChooseViewController.lastProfileName = ProfileChooseViewController.currentProfileName
        
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController) {
            Self.isBacked = true
        }
    }
    
    
    // MARK : - IBACTIONS
    @IBAction func moreBtn(_ sender: Any) {
        mAlertManager.showAboutActions()
    }
    
    
    // MARK : - Custom Method
    func setupView() {
        // Setup Table & embedded views
        setupTable()
        setupPullRefresh()
        adjustLoading(loading: loadingView)
        showLoading(view: self.view, loading: loadingView)
        
        mDatasourceManager.getAllUserProfile()
    }
    
    func resetView() {
        
        if(mProfileList != nil) {
            mProfileList = nil
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    func performAction(profileList: Array<ProfileModel>) {
        mProfileList = profileList
        
        if(mProfileList != nil) {
            emptyTableApplyData()
        } else {
            emptyTableApplyData()
            showEmptyMessage(localizedKeyString: "empty_list")
        }
        
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        endRefresh()
    }
    
    func cancelAction() {
        return
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mProfileList != nil) {
            return mProfileList.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")
        
        if(mProfileList[indexPath.row].name == ProfileChooseViewController.currentProfileName) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        cell?.textLabel?.text = mProfileList[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProfileChooseViewController.currentProfileName = mProfileList[indexPath.row].name
        ProfileChooseViewController.currentProfileIndex = indexPath.row
        self.tableView.reloadData()
    }
}
