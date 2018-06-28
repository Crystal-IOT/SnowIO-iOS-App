//
//  AppDelegate.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import Firebase

import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ESTBeaconManagerDelegate, BeaconManagerProtocol {

    var window: UIWindow?
    static let language = Locale.current.languageCode!
    
    // Custom Links
    static let APP_STORE_URL = ""
    static let APP_DEVELOPER_URL = "http://emilienleroy.fr/crystal/"
    
    // Style on Navbars
    var navigationBar = UINavigationBar.appearance()
    var tabBar = UITabBar.appearance()
    var searchBar = UIBarButtonItem.appearance()
    
    // HomePage
    static var currentPage: IndexPath = IndexPath(row: 0, section: 1)
    
    // Beacon Manager
    let beaconManager = ESTBeaconManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Data Manager
    var mBeaconList: Array<BeaconModel>!
    var mSkiSlope = Array<SkiSlopeModel>()
    var mSkiStation = Array<StationModel>()


    // MARK : - APP LIFE CYCLE
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Change bar style propertys for all controllers
        navigationBar.tintColor = UIColor().colorFromHexa(rgbValue: UIColor.applicationColor.whiteColor.rawValue)
        navigationBar.barTintColor = UIColor().colorFromHexa(rgbValue: UIColor.applicationColor.primaryColor.rawValue)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        // Change status bar text color
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Change tab bar color for all controllers
        tabBar.tintColor = UIColor().colorFromHexa(rgbValue: UIColor.applicationColor.whiteColor.rawValue)
        tabBar.barTintColor = UIColor().colorFromHexa(rgbValue: UIColor.applicationColor.primaryColor.rawValue)
        
        // Change SearchBar button color
        searchBar.tintColor = UIColor().colorFromHexa(rgbValue: UIColor.applicationColor.whiteColor.rawValue)
        
        // Setup Firebase
        FirebaseApp.configure()
        
        // Setup Notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization.
        })
        
        // Setup Beacon Manager
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        // Setup Beacon Datasource
        self.mDatasourceManager.beaconManagerProtocol = self
        self.mDatasourceManager.getBeaconList()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    
    // MARK : - BeaconManagerProtocol Manager
    func performBeaconAction(beaconList: Array<BeaconModel>) {
        self.mBeaconList = beaconList
        
        if (mBeaconList.isEmpty == false) {
            
            if(mSkiSlope.isEmpty == false) {
                mSkiSlope.removeAll()
            }
            
            for beacon in mBeaconList {
                self.mDatasourceManager.getSkiSlopeAssociated(idSkiSlope: beacon.idSkiSlope)
            }
            setupBeaconDevices()
        }
    }
    
    func performSkiSlopeAction(skiSlope: SkiSlopeModel) {
        self.mSkiSlope.append(skiSlope)
        self.mDatasourceManager.getSkiStationAssociated(idStation : skiSlope.idStation)
    }
    
    func performSkiStationAction(skiStation: StationModel) {
        self.mSkiStation.append(skiStation)
    }
    
    func cancelAction() {
    }
    
    
    // MARK: - CUSTOM METHODS FOR BEACON MANAGER
    func setupBeaconDevices() {
        for beacon in mBeaconList {
            self.beaconManager.startMonitoring(for: CLBeaconRegion(
                proximityUUID: UUID(uuidString: beacon.beaconID)!,
                major: CLBeaconMajorValue(beacon.major),
                minor: CLBeaconMinorValue(beacon.minor),
                identifier: "monitored_" + beacon.name))
        }
    }
    
    
    // MARK : - ESTBeaconManagerDelegate Methods
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        if(mBeaconList != nil) {
            let uuidString = UUID().uuidString
            
            let triggeredBeacon = mBeaconList.index(where: { $0.beaconID == region.proximityUUID.uuidString})
            let skiSlopeName = self.mSkiSlope[triggeredBeacon!].name
            let skiStationName = " (" + self.mSkiStation[triggeredBeacon!].name + ")"
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = mDatasourceManager.getFormattedBeaconText(text: mBeaconList[triggeredBeacon!].beaconPlacement!) + skiSlopeName! + skiStationName
            

            let request = UNNotificationRequest(identifier: uuidString,
                                                content: notificationContent,
                                                trigger: nil)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // Handle any errors.
                }
            }
        }
    }
  
    
    // MARK : - UNUserNotificationCenterDelegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Snow_IO")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

