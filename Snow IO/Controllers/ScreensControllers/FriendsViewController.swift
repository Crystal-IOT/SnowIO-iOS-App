//
//  FriendsViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class FriendsViewController: UITableViewController, UserFriendsProtocol, pullRefreshProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mAlertManager = AlertsManager()
    var mPrefs = Preferences()
    
    var mDatasourceManager = SnowIOFirebaseManager()
    var mFriendList: Array<UserModel>!
    
    // Segue Variables
    var selectedIndex = 0
    var friendPosition: PositionModel?
    let mapIdentifier = "mapSegue"
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userFriendProtocol = self
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(DrawerViewController.isOpen == false) {
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
        
        mDatasourceManager.getFriendsList()
    }
    
    func resetView() {
        
        if(mFriendList?.isEmpty == false) {
            mFriendList?.removeAll()
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    // MARK : Crystal-IOT DataSource Methods
    func performAction(friendsList: Array<UserModel>) {
        mFriendList = friendsList
        
        if(mFriendList?.isEmpty == true) {
            emptyTableApplyData()
            showEmptyMessage(localizedKeyString: "empty_list")
        } else {
            hasValueTableApplyData()
        }
        
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        endRefresh()
    }
    
    func cancelAction() {
        emptyTableApplyData()
        removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        showEmptyMessage(localizedKeyString: "api_error_server")
        endRefresh()
    }
    
    // MARK : Pull To Refresh DataSource Methods
    func reloadData() {
        showLoading(view: self.view, loading: loadingView)
        resetView()
        mDatasourceManager.getFriendsList()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mFriendList != nil) {
            return mFriendList.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as? friendsCell
        
        if(mFriendList[indexPath.row].picture != "nil") {
            cell?.usernameImage.image = PictureManager().decodeStringToImage(image: mFriendList[indexPath.row].picture)
        }
    
        cell?.friendName.text = mFriendList[indexPath.row].firstname + " " + mFriendList[indexPath.row].lastname
            
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.friendPosition = mFriendList[indexPath.row].position
        self.performSegue(withIdentifier: self.mapIdentifier, sender: self)
    }

    // MARK : - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc: DrawerViewController = segue.destination as? DrawerViewController {
            if segue.identifier == mapIdentifier {
                AppDelegate.currentPage = IndexPath(row: 3, section: 1)
                vc.actionToPerform = mapIdentifier
                vc.mapData = friendPosition
            }
        }
    }
}

class friendsCell : UITableViewCell {
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendPosition: UIButton!
}
