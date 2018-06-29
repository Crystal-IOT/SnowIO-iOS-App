//
//  SnowIOFirebaseActions.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import ObjectMapper

extension SnowIOFirebaseManager {
    
    private func setupDatabase() {
        databaseRef = Database.database().reference()
    }
    
    
    // **
    // ** MARK : GET ALL PROFILES TYPE
    // **
    func getAllUserProfile() {
        setupDatabase()
        
        var languageChild = ""
        if(AppDelegate.language != "fr") {
            languageChild = "en"
        } else {
            languageChild = AppDelegate.language
        }
        
        var profileList = Array<ProfileModel>()
        
        databaseRef.child("profil").child(languageChild).observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myProfile = Mapper<ProfileModel>().map(JSONObject: rest.value)!
                profileList.append(myProfile)
            }
            self.userAuthenticationProfileProtocol?.performAction(profileList: profileList)
        })
    }
    
    
    // **
    // ** MARK : SIGN UP USER
    // **
    func performSignUp(user: UserModel, password: String) {
        setupDatabase()
        let userDictionnary = user.description
        
        // Create User in firebase Authentication before
        Auth.auth().createUser(withEmail: user.email, password: password, completion: { (user, error) in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .accountExistsWithDifferentCredential:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("account_already_exists", comment: ""))
                    default:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                }
                self.userAuthenticationProtocol?.cancelBasicAction()
                return
            }
            
            self.databaseRef.child("users").child((user?.user.uid)!).setValue(userDictionnary, withCompletionBlock: { (error, databaseRef) in
                if error == nil {
                    self.userAuthenticationProtocol?.performBasicAction()
                } else {
                    self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: String(describing: error?.localizedDescription))
                }
            })
        })
    }
    
    
    // **
    // ** MARK : LOGIN USER
    // **
    func performLogin(email: String, password: String) {
        setupDatabase()
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("account_valid_email", comment: ""))
                    case .invalidCredential:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("account_valid_credentials", comment: ""))
                    case .emailAlreadyInUse:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("account_already_email", comment: ""))
                    default:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                }
                self.userAuthenticationProtocol?.cancelBasicAction()
                return
            }

            self.mPrefs.userEmail = user?.user.email
            self.mPrefs.userPassword = password
            self.mPrefs.userToken = user?.user.refreshToken
            
            self.userAuthenticationProtocol?.performBasicAction()
        })
        
    }
    
    
    // **
    // ** MARK : GET CURRENT USER PROFILE
    // **
    func getCurrentUserProfile(email: String) {
        setupDatabase()
        
        var myUser = UserModel.init()
        var myProfile = ProfileModel.init()
        
        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                myUser = Mapper<UserModel>().map(JSONObject: rest.value)!
            }
            
            var languageChild = ""
            if(AppDelegate.language != "fr") {
                languageChild = "en"
            } else {
                languageChild = AppDelegate.language
            }
            
            if(myUser != nil) {
                let idProfil = String(describing: myUser.idProfil!)
                self.databaseRef.child("profil").child(languageChild).child(idProfil).observeSingleEvent(of: .value, with: { snapshot in
                    myProfile = Mapper<ProfileModel>().map(JSONObject: snapshot.value)!
                    self.userProfileProtocol?.performAction(userAccount: myUser, userProfile: myProfile)
                    self.reloadDataProtocol?.reloadInformations(displaying: true)
                })
            } else {
                self.userProfileProtocol?.cancelAction()
            }
        })
    }
    
    
    // **
    // ** MARK : SET USER PROFILE
    // **
    func setCurrentUserProfile(userToUpdate: UserModel) {
        setupDatabase()
        
        MenuTableViewController.stopHeaderTimer()
        
        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: mPrefs.userEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let userKey = rest.key
                
                let userRef = self.databaseRef.child("users").child(userKey)
                userRef.updateChildValues(userToUpdate.description)
            }
            self.performUpdateEmail(email: userToUpdate.email)
        })
    }
    
    
    // **
    // ** MARK : SET PICTURE USER PROFILE
    // **
    func setCurrentUserEmail(userMail: String) {
        setupDatabase()
        
        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: mPrefs.userEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let userKey = rest.key
                
                let userRef = self.databaseRef.child("users").child(userKey)
                userRef.updateChildValues(["email" : userMail])
            }
            
            self.mPrefs.userEmail = userMail
            MenuTableViewController.initHeaderTimer()
            self.userProfileProtocol?.performUpdateAction()
        })
    }

    
    // **
    // ** MARK : SET PICTURE USER PROFILE
    // **
    func setCurrentUserPicture(picture: String, userMail: String) {
        setupDatabase()
        
        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: userMail).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let userKey = rest.key
                
                let userRef = self.databaseRef.child("users").child(userKey)
                userRef.updateChildValues(["picture" : picture])
            }
        })
    }
    
    
    // **
    // ** MARK : SET POSITION USER PROFILE
    // **
    func setCurrentUserPosition(position: PositionModel, userMail: String) {
        setupDatabase()
        
        let positionDictionnary = position.description
        
        databaseRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: userMail).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let userKey = rest.key
                
                let userRef = self.databaseRef.child("users").child(userKey)
                userRef.updateChildValues(["position" : positionDictionnary])
            }
        })
    }
   
    
    // **
    // ** MARK : RESET PASSWORD FOR USER
    // **
    func performPasswordReset(email: String) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    default:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                }
                self.userAuthenticationProtocol?.cancelBasicAction()
                return
            }
            self.userAuthenticationProtocol?.performBasicAction()
        }
        
    }
    
    
    // **
    // ** MARK : UPDATE PASSWORD FOR USER
    // **
    func performUpdatePassword(password: String) {
        let credential = EmailAuthProvider.credential(withEmail: mPrefs.userEmail!, password: mPrefs.userPassword!)
        
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { _, error in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    default:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                }
                self.userProfileProtocol?.cancelAction()
            } else {
                Auth.auth().currentUser?.updatePassword(to: password, completion: { error in
                    
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            switch errCode {
                            default:
                                self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                            }
                        }
                        self.userProfileProtocol?.cancelAction()
                    } else {
                        self.mPrefs.userPassword = password
                        self.userProfileProtocol?.performUpdateAction()
                    }
                })
            }
        })
    }
    
    
    // **
    // ** MARK : UPDATE EMAIL FOR USER
    // **
    func performUpdateEmail(email: String) {
        let credential = EmailAuthProvider.credential(withEmail: mPrefs.userEmail!, password: mPrefs.userPassword!)
        
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { _, error in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    default:
                        self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                    }
                }
                self.userProfileProtocol?.cancelAction()
                return
            } else {
                Auth.auth().currentUser?.updateEmail(to: email, completion: { error in
                    
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            switch errCode {
                            default:
                                self.mAlertManager.showAlert(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription)
                            }
                        }
                        self.userProfileProtocol?.cancelAction()
                        return
                    }
                    self.setCurrentUserEmail(userMail: email)
                })
            }
        })
    }
    
    
    // **
    // ** MARK : GET FRIENDS LIST
    // **
    func getFriendsList() {
        setupDatabase()
        
        var friendsList = Array<UserModel>()
        
        databaseRef.child("users").queryOrdered(byChild: "email").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myUser = Mapper<UserModel>().map(JSONObject: rest.value)!
                
                if(self.mPrefs.userEmail != myUser.email) {
                    friendsList.append(myUser)
                }
            }
            self.userFriendProtocol?.performAction(friendsList: friendsList)
        })
    }
    
    
    // **
    // ** MARK : GET STATION LIST
    // **
    func getStationsList() {
        setupDatabase()
        
        var stationsList = Array<StationModel>()
        
        databaseRef.child("stations").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myStation = Mapper<StationModel>().map(JSONObject: rest.value)!
                stationsList.append(myStation)
            }
            self.userStationProtocol?.performAction(stationList: stationsList)
        })
    }
    
    
    // **
    // ** mARK : GET STATION ID
    // **
    func getStationID(station: StationModel) {
        setupDatabase()
        
        var stationID = ""
        
        databaseRef.child("stations").queryOrdered(byChild: "name").queryEqual(toValue: station.name).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                stationID = rest.key
            }
            self.userHomeProtocol?.performStationIDAction(stationID: stationID)
        })
    }
    
    
    // **
    // ** MARK : GET CATEGORIES INTEREST LIST
    // **
    func getCategoriesInteresetList() {
        setupDatabase()
        
        var catInterestsList = Array<InterestCategorie>()
        
        databaseRef.child("categoriesInterests").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myCategorie = Mapper<InterestCategorie>().map(JSONObject: rest.value)!
                catInterestsList.append(myCategorie)
            }
            self.userCategorieInterestProtocol?.performAction(categorieInterestsList: catInterestsList)
        })
    }
    
    
    // **
    // ** MARK : GET INTEREST LIST FROM CATEGORIES CHOOSE
    // **
    func getCategoriesInteresetList(categorieChoose: String) {
        setupDatabase()
        
        var interestsList = Array<InterestModel>()
        
        databaseRef.child("interests").child(categorieChoose).observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myInterest = Mapper<InterestModel>().map(JSONObject: rest.value)!
                interestsList.append(myInterest)
            }
            self.userInterestProtocol?.performAction(interestsList: interestsList)
        })
    }
    
    
    // **
    // ** MARK : GET SKISLOPE LIST FOR ONE STATION
    // **
    func getSkiSlopeListForStation(idStation: String) {
        setupDatabase()
        
        var skiSlopeList = Array<SkiSlopeModel>()
        
        databaseRef.child("skiSlope").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let mSkiSlope = Mapper<SkiSlopeModel>().map(JSONObject: rest.value)!
                skiSlopeList.append(mSkiSlope)
            }
            skiSlopeList = skiSlopeList.filter({ $0.idStation == idStation })
            
            self.userHomeProtocol?.performStationSkiSlopeAction(skiSlope: skiSlopeList)
        })
    }
    
    // **
    // ** MARK : GET SKISLOPE ID
    func getSkiSlopeID(skiSlope: SkiSlopeModel) {
        setupDatabase()
        
        var skiSlopeID = ""
        
        databaseRef.child("skiSlope").queryOrdered(byChild: "name").queryEqual(toValue: skiSlope.name).observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                skiSlopeID = rest.key
            }
            self.userHomeProtocol?.performStationSkiSlopeIDAction(skiSlopeID: skiSlopeID)
        })
    }
    
    
    // **
    // ** MARK : GET SKISLOPE LEVEL LIST
    // **
    func getSkiSlopeLevel() {
        setupDatabase()
        
        var languageChild = ""
        if(AppDelegate.language != "fr") {
            languageChild = "en"
        } else {
            languageChild = AppDelegate.language
        }
        
        var slopeLevelList = Array<SkiSlopeLevel>()
        
        databaseRef.child("skiSlopeLevel").child(languageChild).observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let mSkiSlopeLevel = Mapper<SkiSlopeLevel>().map(JSONObject: rest.value)!
                slopeLevelList.append(mSkiSlopeLevel)
            }
            self.userHomeProtocol?.performStationSkiSlopeLevelAction(skiSlopeLevelList: slopeLevelList)
        })
    }
    
    
    // **
    // ** MARK : GET ONE SKISLOPE FOR ONE BEACON
    // **
    func getSkiSlopeAssociated(idSkiSlope: String) {
        setupDatabase()
        
        databaseRef.child("skiSlope").child(idSkiSlope).observeSingleEvent(of: .value, with: { snapshot in
            let mSkiSlope = Mapper<SkiSlopeModel>().map(JSONObject: snapshot.value)!
            self.beaconManagerProtocol?.performSkiSlopeAction(skiSlope: mSkiSlope)
        })
    }
    
    
    // **
    // ** MARK : GET ONE SKISTATION FOR ONE BEACON
    // **
    func getSkiStationAssociated(idStation: String) {
        setupDatabase()
        
        databaseRef.child("stations").child(idStation).observeSingleEvent(of: .value, with: { snapshot in
            let mSkiStation = Mapper<StationModel>().map(JSONObject: snapshot.value)!
            self.beaconManagerProtocol?.performSkiStationAction(skiStation: mSkiStation)
        })
    }
    
    
    // **
    // ** MARK : GET BEACON LIST
    // **
    func getBeaconList() {
        setupDatabase()
        
        var beaconList = Array<BeaconModel>()
        
        databaseRef.child("beaconsManager").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myBeacon = Mapper<BeaconModel>().map(JSONObject: rest.value)!
                beaconList.append(myBeacon)
            }
            self.beaconManagerProtocol?.performBeaconAction(beaconList: beaconList)
        })
    }
    
    // **
    // ** MARK : GET BEACON LIST FOR SKI SLOPE
    func getBeaconListForSkiSlope(skiSlopeID : String) {
        setupDatabase()
        
        var beaconList = Array<BeaconModel>()
        
        databaseRef.child("beaconsManager").observeSingleEvent(of: .value, with: { snapshot in
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                let myBeacon = Mapper<BeaconModel>().map(JSONObject: rest.value)!
                beaconList.append(myBeacon)
            }
            beaconList = beaconList.filter({ $0.idSkiSlope == skiSlopeID})
            self.userHomeProtocol?.performBeaconListAction(beaconList: beaconList)
        })
    }
}

