//
//  LoginLogoutManager.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UIView {
    
    func performLogin() {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVCAfterLoginScreen") as! DrawerViewController
        UIApplication.shared.keyWindow?.rootViewController = rootVC
    }
    
    func performLogout() {
        Preferences().resetData()
        let rootVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "navLoginVC") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = rootVC
    }
    
    func performRestart() {
        AppDelegate.currentPage = IndexPath(row: 0, section: 1)
        let rootVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "navLoginVC") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = rootVC
    }
}
