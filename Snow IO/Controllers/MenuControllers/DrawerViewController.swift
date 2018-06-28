//
//  DrawerViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: KYDrawerController, KYDrawerControllerDelegate {
    
    // DrawerState
    static var isOpen: Bool?
    
    // Menus
    let myMenu = MenuTableViewController()
    var actionToPerform: String = ""
    
    // MapData
    var mapData: PositionModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Variables
        self.delegate = self
        self.drawerWidth = 300
        
        // Setup DrawerState
        DrawerViewController.isOpen = false
        
        if(actionToPerform != "") {
            performSegue(withIdentifier: actionToPerform, sender: self)
            self.mainSegueIdentifier = actionToPerform
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == myMenu.homeIdentifier {
            _ = segue.destination as? UINavigationController
        }
        
        if segue.identifier == myMenu.profileIdentifer {
            _ = segue.destination as? UINavigationController
        }
        
        if segue.identifier == myMenu.friendsIdentifier {
            _ = segue.destination as? UINavigationController
        }
        
        if segue.identifier == myMenu.mapIdentifier {
            let mapScreen = segue.destination.childViewControllers[0] as? MapViewController
            
            if(self.mapData != nil) {
                mapScreen?.objectPosition = mapData
                mapData = nil
            }
        }
        
        if segue.identifier == myMenu.activitiesIdentifier {
            _ = segue.destination as? UINavigationController
        }
    }
    
    // MARK : KYDrawerControllerDelegate Methods
    func drawerController(_ drawerController: KYDrawerController, willChangeState state: KYDrawerController.DrawerState) {
        if(state == DrawerViewController.DrawerState.closed) {
            DrawerViewController.isOpen = false
        } else {
            DrawerViewController.isOpen = true
        }
    }
    
    
}
