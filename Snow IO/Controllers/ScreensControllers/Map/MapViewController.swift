//
//  MapViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import JKBottomSearchView
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,
UserFriendsProtocol, UserStationProtocol, UserCategorieInterestsProtocol, UserInterestsProtocol, BeaconManagerProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BottomSearch
    let bottomSearchView = JKBottomSearchView()
    
    // Managers
    var mAlertManager = AlertsManager()
    var mPrefs = Preferences()
    
    // DataSources
    var mDatasourceManager = SnowIOFirebaseManager.sharedInstance
    
    // Datas
    var mFriendList: Array<UserModel>!
    var mBeaconList : Array<BeaconModel>!
    var mCatInterestList: Array<InterestCategorie>!
    var mInterestList = Array<InterestModel>()
    var mSkiSlope = Array<SkiSlopeModel>()
    var mSkiStationAssociated = Array<StationModel>()
    
    var mStationList : Array<StationModel>!
    var mFilteredStationList = Array<StationModel>()
    
    // LocationManager
    let mManager = CLLocationManager()
    
    // Friend position
    var objectPosition: PositionModel?
    
    // Utils variables
    var dataStationIsDisplay = false
    var dataSationIsReadyToDisplay = false
    
    // Segue Variables
    static var selectedStation: StationModel?
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gpsButton: UIBarButtonItem!
    
    
    
    // MARK : - App Life Cycle
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
    
    @IBAction func locationBtn(_ sender: Any) {
        enableLocationServices()
        gpsButton.isEnabled = false
        
        showLoading(view: self.view, loading: loadingView)
        mManager.requestLocation()
    }
    
    
    @IBAction func moreBtn(_ sender: Any) {
        mAlertManager.showAboutActions()
    }
    
    
    // MARK : - Custom Methods
    func setupView() {
        // Add Datasource delegate
        mDatasourceManager.userFriendProtocol = self
        mDatasourceManager.userStationProtocol = self
        mDatasourceManager.beaconManagerProtocol = self
        mDatasourceManager.userCategorieInterestProtocol = self
        mDatasourceManager.userInterestProtocol = self
        
        // Add GPS delegate
        mManager.delegate = self
        mManager.desiredAccuracy = kCLLocationAccuracyBest
        gpsButton.isEnabled = false
        
        // Add Maps delegate
        mapView.delegate = self
        mapView.register(basicUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(basicStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(basicBeaconAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(basicInterestAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // Add BottomSearch Pods
        setupBottomSearchView()
        
        // Show Loading
        showLoading(view: self.view, loading: loadingView)
        
        // Get Data
        mDatasourceManager.getBeaconList()
    }
    
    func resetView() {
        removeEmptyMessage()
    }
    
    
    // MARK : Crystal-IOT DataSource Methods - Friends & stations informations
    func performBeaconAction(beaconList: Array<BeaconModel>) {
        mBeaconList = beaconList
        
        if (mBeaconList?.isEmpty == false) {
            for beacon in mBeaconList {
                self.mDatasourceManager.getSkiSlopeAssociated(idSkiSlope: beacon.idSkiSlope)
            }
        }
        
        mDatasourceManager.getFriendsList()
        mDatasourceManager.getStationsList()
        mDatasourceManager.getCategoriesInteresetList()
    }
    
    func performAction(friendsList: Array<UserModel>) {
        mFriendList = friendsList
        
        if(mFriendList?.isEmpty == false) {
            for friend in mFriendList {
                let location2D = CLLocationCoordinate2D(latitude: friend.position.latitude, longitude: friend.position.longitude)
                addMapAnnotation(title: friend.firstname + " " + friend.lastname,
                                 subtitle: friend.firstname + NSLocalizedString("friends_position", comment: ""),
                                 type: .user,
                                 location2D: location2D,
                                 image: friend.picture)
            }
        }
    }
    
    func performAction(stationList: Array<StationModel>) {
        mStationList = stationList
        
        if(mStationList?.isEmpty == false) {
            for station in mStationList {
                let location2D = CLLocationCoordinate2D(latitude: station.position.latitude, longitude: station.position.longitude)
                addMapAnnotation(title: station.name,
                                 subtitle: NSLocalizedString("station_phone", comment: "") + station.phone,
                                 type: .station,
                                 location2D: location2D,
                                 image: "nil")
            }
            
            bottomSearchView.tableView.reloadData()
        }
    }
    
    func performSkiSlopeAction(skiSlope: SkiSlopeModel) {
        self.mSkiSlope.append(skiSlope)
        self.mDatasourceManager.getSkiStationAssociated(idStation : skiSlope.idStation)
    }
    
    func performSkiStationAction(skiStation: StationModel) {
        self.mSkiStationAssociated.append(skiStation)
    }
    
    func performAction(categorieInterestsList: Array<InterestCategorie>) {
        mCatInterestList = categorieInterestsList
        
        for categorie in mCatInterestList {
            self.mDatasourceManager.getCategoriesInteresetList(categorieChoose: categorie.name)
        }
    }
    
    func performAction(interestsList: Array<InterestModel>) {
        for item in interestsList {
            mInterestList.append(item)
        }
        
        if(objectPosition != nil) {
            let objPosition = CLLocation(latitude: (objectPosition?.latitude)!, longitude: (objectPosition?.longitude)!)
            centerMapOnLocation(location: objPosition, regionRadius: 100)
        }
        
        gpsButton.isEnabled = true
        cancelAction()
    }
    
    func cancelAction() {
        removeLoadingView(loadingView: loadingView)
    }
}

// MARK : - MapView Methods, Delegate & Datasources
extension MapViewController {
    
    // MARK : - Custom methods
    func getCurrentZoom() -> Double {
        
        var angleCamera = mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        
        let angleRad = .pi * angleCamera / 180
        
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        
        let offset : Double = 20 // offset of Windows (StatusBar)
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - offset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1;
    }
    
    
    // MARK : - MapView Custom Methods
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        removeLoadingView(loadingView: loadingView)
    }
    
    func addMapAnnotation(title: String, subtitle: String, type: basicAnnotationType, location2D: CLLocationCoordinate2D, image: String) {
        let annotation = basicAnnotation(title : title, subtitle: subtitle, type: type, coordinate: location2D, image: image)
        mapView.addAnnotation(annotation)
    }
    
    
    // MARK : - MapView Delegate & Datasources
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? basicAnnotation else { return nil }
        
        switch annotation.type {
        case .user:
            return basicUserAnnotationView(annotation: annotation, reuseIdentifier: basicUserAnnotationView.reuseID)
        case .station:
            return basicStationAnnotationView(annotation: annotation, reuseIdentifier: basicStationAnnotationView.reuseID)
        case .beacon:
            return basicBeaconAnnotationView(annotation: annotation, reuseIdentifier: basicBeaconAnnotationView.reuseID)
        case .interest:
            return basicInterestAnnotationView(annotation: annotation, reuseIdentifier: basicInterestAnnotationView.reuseID)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (getCurrentZoom() > 13 && dataStationIsDisplay == false) {
            
            for (index, beacon) in mBeaconList.enumerated() {
                let skiSlopeName = self.mSkiSlope[index].name
                let skiStationName = " (" + self.mSkiStationAssociated[index].name + ")"
                let location2D = CLLocationCoordinate2D(latitude: beacon.beaconPosition.latitude,
                                                        longitude: beacon.beaconPosition.longitude)
                
                addMapAnnotation(title: NSLocalizedString("beacon_name", comment: "") + beacon.name.firstUppercased,
                                 subtitle: NSLocalizedString("beacon_position", comment: "") + skiSlopeName! + skiStationName,
                                 type: .beacon,
                                 location2D: location2D,
                                 image: "nil")
            }
            
            for interest in mInterestList {
                let index = interest.idStation!
                let location2D = CLLocationCoordinate2D(latitude: interest.position.latitude,
                                                        longitude: interest.position.longitude)
                
                addMapAnnotation(title: interest.name.firstUppercased,
                                 subtitle: NSLocalizedString("interest_location", comment: "") + self.mSkiStationAssociated[index].name,
                                 type: .interest,
                                 location2D: location2D,
                                 image: interest.image)
                
            }
            self.dataStationIsDisplay = true
        }
        
        if(getCurrentZoom() <= 13) {
            var annotations = mapView.annotations.filter({ $0 as? basicAnnotation != nil ? true : false }) as? [basicAnnotation]
            annotations = annotations?.filter({ $0.type == basicAnnotationType.beacon || $0.type == basicAnnotationType.interest })
            
            if(annotations != nil && annotations?.isEmpty == false) {
                mapView.removeAnnotations(annotations!)
                self.dataStationIsDisplay = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! basicAnnotation
        
        if(location.type != .beacon) {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        }
    }
}

// MARK : - JKBottomSearchDataSource Delegate & Datasources
extension MapViewController: JKBottomSearchDataSource, JKBottomSearchViewDelegate {
 
    func setupBottomSearchView() {
        self.view.addSubview(bottomSearchView)
        
        bottomSearchView.delegate = self
        bottomSearchView.dataSource = self
        
        bottomSearchView.placeholder = NSLocalizedString("search_station", comment: "")
        bottomSearchView.searchBarStyle = .minimal
        bottomSearchView.tableView.backgroundColor = .clear
        bottomSearchView.contentView.layer.cornerRadius = 10
        bottomSearchView.contentView.backgroundColor = UIColor.white
    }
    

    // MARK : SearchBar Controlelr Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        bottomSearchView.toggleExpand(.fullyExpanded)
        filterContentForSearchText (searchText)
    }
    
    func searchBarIsEmpty() -> Bool {
        return (bottomSearchView.searchBarTextField.text?.isEmpty)!
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        mFilteredStationList = mStationList.filter({( categorie : StationModel) -> Bool in
            let doesCategoryMatch = (scope == "All") || (categorie.name == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return categorie.name.lowercased().contains(searchText.lowercased())
            }
        })
        bottomSearchView.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    
    // Mark : - Tableview BottomSearchView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return mFilteredStationList.count
        } else {
            if(mStationList != nil) {
                return mStationList.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if isFiltering() {
            
            if(mFilteredStationList[indexPath.row].name == MapViewController.selectedStation?.name) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            cell.textLabel?.text = mFilteredStationList[indexPath.row].name
            cell.detailTextLabel?.text = mFilteredStationList[indexPath.row].phone
        }
        else {
            
            if(mStationList[indexPath.row].name == MapViewController.selectedStation?.name) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            cell.textLabel?.text = mStationList[indexPath.row].name
            cell.detailTextLabel?.text = mStationList[indexPath.row].phone
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            MapViewController.selectedStation = mFilteredStationList[indexPath.row]
        
            let stationLocation = CLLocation(latitude: mFilteredStationList[indexPath.row].position.latitude,
                                             longitude: mFilteredStationList[indexPath.row].position.longitude)
            
            centerMapOnLocation(location: stationLocation, regionRadius: 100)
        } else {
            MapViewController.selectedStation = mStationList[indexPath.row]
            
            let stationLocation = CLLocation(latitude: mStationList[indexPath.row].position.latitude,
                                             longitude: mStationList[indexPath.row].position.longitude)
            
            centerMapOnLocation(location: stationLocation, regionRadius: 100)
        }
        
        bottomSearchView.toggleExpand(.fullyCollapsed)
        bottomSearchView.endEditing(false)
        bottomSearchView.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK : - CLLocationManager Methods, Delegate & Datasources
extension MapViewController {
    
    // MARK : - CLLocationManager Delegate & Datasources
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    if let location = locations.first
        {
            let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            centerMapOnLocation(location: location, regionRadius: 100000)
         
            gpsButton.image = UIImage(named: "ic_gps_fixed")
            gpsButton.isEnabled = true
            mManager.stopUpdatingLocation()
            
            let userPosition = PositionModel.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if(mDatasourceManager.mUser.position.latitude != userPosition.latitude || mDatasourceManager.mUser.position.longitude != userPosition.longitude) {
                mDatasourceManager.setCurrentUserPosition(position: userPosition, userMail: mPrefs.userEmail!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        mAlertManager.showAlert(title:NSLocalizedString("error", comment: ""), message: error.localizedDescription)
        cancelAction()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableLocationServices()
    }
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            mManager.requestWhenInUseAuthorization()
            gpsButton.image = UIImage(named: "ic_gps_not_fixed")
            break
            
        case .restricted, .denied:
            // Disable location features
            gpsButton.image = UIImage(named: "ic_gps_off")
            gpsButton.isEnabled = false
            mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""),
                                    message: NSLocalizedString("gps_authorization_denied", comment: ""))
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            mManager.requestAlwaysAuthorization()
            gpsButton.image = UIImage(named: "ic_gps_not_fixed")
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            mManager.requestAlwaysAuthorization()
            gpsButton.image = UIImage(named: "ic_gps_not_fixed")
            break
        }
    }
}


