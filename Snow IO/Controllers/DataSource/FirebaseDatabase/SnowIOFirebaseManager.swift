//
//  SnowIOFirebaseManager.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import Firebase
import FirebaseDatabase
import ObjectMapper

class SnowIOFirebaseManager {
    
    // Database Reference
    var databaseRef: DatabaseReference!
    
    // Singleton
    static let sharedInstance = SnowIOFirebaseManager()
    var mUser: UserModel!
    
    // Managers
    let mAlertManager = AlertsManager()
    let mPrefs = Preferences()
    
    // Utils protocol
    var reloadDataProtocol : reloadDataProtocol?
    
    // DataSources protocol
    var beaconManagerProtocol: BeaconManagerProtocol?

    var userHomeProtocol: UserHomeProtocol?
    
    var userAuthenticationProtocol: UserAuthenticationProtocol?
    var userAuthenticationProfileProtocol: UserProfilAuthenticationProtocol?
    var userProfileProtocol: UserProfileProtocol?
    
    var userFriendProtocol: UserFriendsProtocol?
    var userStationProtocol: UserStationProtocol?
    
    var userCategorieInterestProtocol: UserCategorieInterestsProtocol?
    var userInterestProtocol: UserInterestsProtocol?
    
    // Get formatted InterestDate from Datasource
    func getFormattedInterestsDate(index : Int) -> String {
        switch index {
        case 0:
            return NSLocalizedString("interest_day_monday", comment: "")
        case 1:
            return NSLocalizedString("interest_day_tuesday", comment: "")
        case 2:
            return NSLocalizedString("interest_day_wednesday", comment: "")
        case 3:
            return NSLocalizedString("interest_day_thursday", comment: "")
        case 4:
            return NSLocalizedString("interest_day_friday", comment: "")
        case 5:
            return NSLocalizedString("interest_day_saturday", comment: "")
        case 6:
            return NSLocalizedString("interest_day_sunday", comment: "")
        default:
            return ""
        }
    }
    
    // Get formatted BeaconText from Datsource
    func getFormattedBeaconText(text: String) -> String {
        switch text {
        case "up":
            return NSLocalizedString("up_informations", comment: "")
        case "down":
            return NSLocalizedString("down_informations", comment: "")
        default:
            return ""
        }
    }
    
    // Get formatted BeaconText from Datsource
    func getFormattedBeaconTextShort(text: String) -> String {
        switch text {
        case "up":
            return NSLocalizedString("up_informations_short", comment: "")
        case "down":
            return NSLocalizedString("down_informations_short", comment: "")
        default:
            return ""
        }
    }
    
    // Get formatted InterestName from Datasource
    /*func getFormattedInterestsName(level: String) -> String {
        switch level {
        case "hotel":
            return ""
        case "restaurant":
            return ""
        case "toilet":
            return ""
        case "others":
            return ""
        default:
            return ""
        }
    }*/

}
