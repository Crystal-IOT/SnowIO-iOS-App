//
//  UIColorExtension.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UIColor {
    
    enum applicationColor: UInt32 {
        case primaryColor = 0x3AD0FF
        case primaryDarkColor = 0x303F9F
        case whiteColor = 0xFFFFFF
    }
    
    func colorFromHexa(rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func colorFromHexaHalfAlpha(rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:0.5)
    }
    
}
