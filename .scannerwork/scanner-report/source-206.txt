//
//  AlertsManager.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class AlertsManager {
    
    // **
    // ** MARK : BASIC ALERT
    // **
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: NSLocalizedString("btn_ok", comment: ""), style: .cancel, handler: { action in
        })
        
        alert.addAction(retryAction)
        
        let currentTopVC: UIViewController? = self.currentTopViewController()
        currentTopVC?.present(alert, animated: true)
    }
    
    // **
    // ** MARK : HELP / HOW TO PLAY ALERT
    // **
    func showHelpAlert() {
        
        let title = NSLocalizedString("txt_help", comment: "")
        let message = NSLocalizedString("txt_helpPage", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("btn_ok", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        let currentTopVC: UIViewController? = self.currentTopViewController()
        currentTopVC?.present(alert, animated: true)
    }
    
    // **
    // ** MARK : NETWORK ALERT
    // **
    func showNetworkAlert(message: String, view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("txt_network", comment: "") , message: message, preferredStyle: .alert)
        
        let restartAction  = UIAlertAction(title: NSLocalizedString("btn_restart", comment: ""), style: .default, handler: { action in
            view.performRestart()
        })
        
        alert.addAction(restartAction)
        
        let currentTopVC: UIViewController? = self.currentTopViewController()
        currentTopVC?.present(alert, animated: true)
    }
    
    // **
    // ** MARK : ABOUT ALERT
    // **
    func showAboutActions() {
        
        let alert = UIAlertController(title: NSLocalizedString("app_info", comment: ""),
                                      message: NSLocalizedString("app_info_description", comment: ""), preferredStyle: .actionSheet)
        
        let aboutAction = UIAlertAction(title: NSLocalizedString("txt_about", comment: ""), style: .default, handler: { action in
            self.showAlert(title: NSLocalizedString("txt_about", comment: ""), message: NSLocalizedString("txt_aboutPage", comment: ""))
        })
        
        let rateAction = UIAlertAction(title: NSLocalizedString("txt_rateme", comment: ""), style: .default, handler: { action in
            if(AppDelegate.APP_STORE_URL != "") {
                if let url = URL(string: AppDelegate.APP_STORE_URL){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                self.showAlert(title: NSLocalizedString("error", comment: ""),
                               message: NSLocalizedString("error_app_publish", comment: ""))
            }
        })
        
        let othersAppsAction = UIAlertAction(title: NSLocalizedString("txt_others", comment: ""), style: .default, handler: { action in
            if(AppDelegate.APP_DEVELOPER_URL != "") {
                if let url = URL(string: AppDelegate.APP_DEVELOPER_URL){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                self.showAlert(title: NSLocalizedString("error", comment: ""),
                               message: NSLocalizedString("error_other_description", comment: ""))
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("btn_cancel", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(aboutAction)
        alert.addAction(rateAction)
        alert.addAction(othersAppsAction)
        alert.addAction(cancelAction)
        
        let currentTopVC: UIViewController? = self.currentTopViewController()
        currentTopVC?.present(alert, animated: true)
    }
    
    // **
    // ** MARK : GET THE TOP VIEW CONTROLLER FOR DISPLAY ALERT ON IT
    // **
    func currentTopViewController() -> UIViewController {
        var topVC: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
        while ((topVC?.presentedViewController) != nil) {
            topVC = topVC?.presentedViewController
        }
        return topVC!
    }
}

