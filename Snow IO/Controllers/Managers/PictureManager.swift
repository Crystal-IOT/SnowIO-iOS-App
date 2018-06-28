//
//  PictureManager.swift
//  Snow IO
//
//  Created by Steven F. on 05/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class PictureManager {
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func encodeImageToBase64String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image,JPEGQuality.high.rawValue)!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func decodeStringToImage(image: String) -> UIImage {
        let imageData = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!
        var image = UIImage(data: imageData)!

        image = resizeImageWithRatio(image: image, newWidth: 200)!
        return image
    }
    
    
    func resizeImageWithRatio(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let newSize = CGSize(width: targetSize.width, height: targetSize.height)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
