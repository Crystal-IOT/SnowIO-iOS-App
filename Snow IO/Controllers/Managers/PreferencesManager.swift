//
//  PreferencesManager.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

import Foundation

class Preferences {
    
    let defaults = UserDefaults.standard
    
    /* Accessors for Users Preference variables */
    var userEmail : String? {
        get {
            return defaults.string(forKey: "userEmail")
        }
        set {
            defaults.set(newValue , forKey: "userEmail")
        }
    }
    
    var userPassword : String? {
        get {
            return defaults.string(forKey: "userPassword")
        }
        set {
            defaults.set(newValue , forKey: "userPassword")
        }
    }
    
    var userToken : String? {
        get {
            return defaults.string(forKey: "userToken")
        }
        set {
            defaults.set(newValue , forKey: "userToken")
        }
    }
    
    
    /* Set default values for first app launch */
    func setDefault()
    {
        if(self.userToken == nil) {
            self.userEmail = ""
            self.userPassword = ""
            self.userToken = ""
        }
    }
    
    func resetData() {
        self.userEmail = ""
        self.userPassword = ""
        self.userToken = ""
    }
    /* END */
    
}

