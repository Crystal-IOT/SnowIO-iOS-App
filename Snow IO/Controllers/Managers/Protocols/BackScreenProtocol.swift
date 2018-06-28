//
//  BackScreenProtocol.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

// Implement this protocol on your mainController will display the details screen
protocol mainBackScreenProtocol {
    associatedtype `previousScreen`: UIViewController
}

protocol mainDoubleBackScreenProtocol {
    associatedtype `previousScreenOne`: UIViewController
    associatedtype `previousScreenTwo`: UIViewController
}

// Implement this protocol on your detailsController will back to your mainController
protocol screenToBackProtocol {
    associatedtype `Self`: UIViewController
    static var isBacked: Bool { get set }
}
