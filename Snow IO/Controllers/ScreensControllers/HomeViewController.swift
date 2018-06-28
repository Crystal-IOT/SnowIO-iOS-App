//
//  HomeViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UITableViewController, pullRefreshProtocol, UserHomeProtocol, reloadDataProtocol {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mAlertManager = AlertsManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    var mPrefs = Preferences()
    
    // Segue Variables
    let mapIdentifier = "mapSegue"
    var mSkiStation = MapViewController.selectedStation
    
    // Data Manager
    var mSkiSlopeID: Array<String> = []
    var mSkiSlope: Array<SkiSlopeModel> = []
    var mSkiSlopeLevel: Array<SkiSlopeLevel> = []
    var mBeaconList: Array<BeaconModel> = []
    
    // Expendable & Utils Variables
    private var arrayCellExpended: Array<Bool> = []
    

    // MARK : - APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        adjustLoading(loading: loadingView)
        showLoading(view: self.view, loading: loadingView)
        
        mDatasourceManager.userHomeProtocol = self
        
        
        if(mSkiStation == nil) {
            
            if(MenuTableViewController.isDisplaying == false) {
                mDatasourceManager.reloadDataProtocol = self
                mDatasourceManager.getCurrentUserProfile(email: mPrefs.userEmail!)
            }
            
            self.tableView.reloadData()
            removeLoadingView(loadingView: loadingView, tableView: self.tableView)
        } else {
            setupPullRefresh()
            mDatasourceManager.getStationID(station: mSkiStation!)
        }
    }
    
    func resetView() {
        
        if(mSkiSlopeID.isEmpty == false) {
            mSkiSlopeID.removeAll()
        }
        
        if(mSkiSlope.isEmpty == false) {
            mSkiSlope.removeAll()
        }
        
        if(mSkiSlopeLevel.isEmpty == false) {
            mSkiSlopeLevel.removeAll()
        }
        
        if(mBeaconList.isEmpty == false) {
            mBeaconList.removeAll()
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    @objc func goToMapScreen() {
        self.performSegue(withIdentifier: self.mapIdentifier, sender: self)
    }
    
    func scrollToBottom(row: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    // MARK : - reloadDataProtocol Manager
    func reloadInformations(displaying: Bool) {
        MenuTableViewController.isDisplaying = displaying
        self.tableView.reloadData()
    }
    
    // MARK : - UserHomeProtocol Manager
    func performStationIDAction(stationID: String) {
        mDatasourceManager.getSkiSlopeListForStation(idStation: stationID)
    }
    
    func performStationSkiSlopeAction(skiSlope: Array<SkiSlopeModel>) {
        self.mSkiSlope = skiSlope
        
        if(mSkiSlope.isEmpty == false) {
           mDatasourceManager.getSkiSlopeLevel()
        } else {
            emptyTableApplyData()
            enabledScroll()
            endRefresh()
            showEmptyMessage(localizedKeyString: "empty_home_slope")
            self.removeLoadingView(loadingView: loadingView)
        }
    }
    
    func performStationSkiSlopeLevelAction(skiSlopeLevelList: Array<SkiSlopeLevel>) {
        self.mSkiSlopeLevel = skiSlopeLevelList
        
        if(mSkiSlopeLevel.isEmpty == false) {
            for skiSlope in mSkiSlope {
                mDatasourceManager.getSkiSlopeID(skiSlope: skiSlope)
            }
            
        }
    }
    
    func performStationSkiSlopeIDAction(skiSlopeID: String) {
        mSkiSlopeID.append(skiSlopeID)
        arrayCellExpended.append(false)
        mDatasourceManager.getBeaconListForSkiSlope(skiSlopeID: skiSlopeID)
    }
    
    func performBeaconListAction(beaconList: Array<BeaconModel>) {
        if(self.mBeaconList.isEmpty) {
            self.mBeaconList = beaconList
        } else {
            for beacon in beaconList {
                self.mBeaconList.append(beacon)
            }
        }
        emptyTableApplyData()
        enabledScroll()
        endRefresh()
        self.removeLoadingView(loadingView: loadingView)
    }
    
    
    // MARK : Pull To Refresh DataSource Methods
    func reloadData() {
        showLoading(view: self.view, loading: loadingView)
        resetView()
        mDatasourceManager.getStationID(station: mSkiStation!)
    }
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mSkiStation == nil) {
            return 1
        } else {
            return mSkiSlope.count+1
        }
     }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(mSkiStation == nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyStationCell", for: indexPath) as? emptyStationCell
            
            cell?.emptyStationTxt.text = NSLocalizedString("choose_station", comment: "")
            cell?.emptyStationBtn.addTarget(self, action: #selector(self.goToMapScreen), for: .touchUpInside)
            
            if(MenuTableViewController.isDisplaying == false) {
                cell?.emptyStationBtn?.disableButton()
            } else {
                cell?.emptyStationBtn?.enabledButton()
            }
            
            return cell!
        } else {
            
            if indexPath.row == 0 {
                
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerStationCell") as? headerStationCell
                
                headerCell?.stationName.text = mSkiStation?.name
                
                headerCell?.stationPhone.textContainer.maximumNumberOfLines = 1
                headerCell?.stationPhone.textContainer.lineBreakMode = .byTruncatingTail
                headerCell?.stationPhone.text = mSkiStation?.phone
                
                //headerCell?.stationMaps.
                
                return headerCell!
                
            } else {
                
                let skiSlopeCell = tableView.dequeueReusableCell(withIdentifier: "skiStationCell") as? skiStationCell
                
                skiSlopeCell?.mTitleText.text = NSLocalizedString("slope_name", comment: "") + mSkiSlope[indexPath.row-1].name
                skiSlopeCell?.mSubtitleText.text = NSLocalizedString("slope_level", comment: "") + mSkiSlopeLevel[mSkiSlope[indexPath.row-1].level].name
            
                var count = 1
                var finalString = "\n\n"
                let beaconList = mBeaconList.filter({ $0.idSkiSlope == mSkiSlopeID[indexPath.row-1]})
                
                for beacon in beaconList {
                    let beaconInformations = beacon.name + " - " + mDatasourceManager.getFormattedBeaconTextShort(text: beacon.beaconPlacement!) + "\n\n"
                    let beaconName = NSLocalizedString("beacon_id", comment: "") + String(describing: count) + " : "
                    let beaconInfos = beaconName + beaconInformations
                    
                    finalString += beaconInfos
                    count = count+1
                }
                
                if(arrayCellExpended[indexPath.row-1] == true) {
                    skiSlopeCell?.mDisclosureImage.image = UIImage(named: "arrow_expanded")
                    skiSlopeCell?.mDisclosureImage.tintColor = UIColor.white
                } else {
                    skiSlopeCell?.mDisclosureImage.image = UIImage(named: "arrow_no_expanded")
                    skiSlopeCell?.mDisclosureImage.tintColor = UIColor.white
                }
                
                if(finalString != "\n\n") {
                    skiSlopeCell?.mDetailText.text = finalString
                } else {
                    finalString += NSLocalizedString("no_object", comment: "") + "\n\n"
                    skiSlopeCell?.mDetailText.text = finalString
                }
                
                return skiSlopeCell!
            }
        }
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if(mSkiStation != nil) {
            if(indexPath.row != 0) {
                if(arrayCellExpended[indexPath.row-1]) {
                    arrayCellExpended[indexPath.row-1] = false
                } else {
                    arrayCellExpended[indexPath.row-1] = true
                }
                
                self.tableView.reloadData()
                scrollToBottom(row: indexPath.row)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(mSkiStation == nil) {
            return 155
        } else {
            if indexPath.row == 0 {
                return 210
            } else {
                if arrayCellExpended[indexPath.row-1] {
                    return UITableViewAutomaticDimension
                } else {
                        return 70
                }
            }
        }
    }
    
    
    // MARK : - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc: DrawerViewController = segue.destination as? DrawerViewController {
            if segue.identifier == mapIdentifier {
                AppDelegate.currentPage = IndexPath(row: 3, section: 1)
                vc.actionToPerform = mapIdentifier
                vc.mapData = nil
            }
        }
    }
}

class emptyStationCell: UITableViewCell {
    @IBOutlet weak var emptyStationTxt: UILabel!
    @IBOutlet weak var emptyStationBtn: actionButtons!
}

class headerStationCell: UITableViewCell {
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationPhone: UITextView!
    @IBOutlet weak var stationMaps: MKMapView!
}

class skiStationCell: UITableViewCell {
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mTitleText: UILabel!
    @IBOutlet weak var mSubtitleText: UILabel!
    @IBOutlet weak var mDetailText: UILabel!
    @IBOutlet weak var mDisclosureImage: UIImageView!
    
    override func awakeFromNib() {
        mDetailText.numberOfLines = 0
        mDetailText.lineBreakMode = .byWordWrapping
        mDetailText.sizeToFit()
        
        mView.sizeToFit()
    }
}
