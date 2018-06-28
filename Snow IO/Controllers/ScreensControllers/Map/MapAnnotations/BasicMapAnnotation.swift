//
//  BasicMapAnnotation.swift
//  Snow IO
//
//  Created by Steven F. on 11/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import Contacts
import MapKit

enum basicAnnotationType: String {
    case user = "user"
    case station = "station"
    case beacon = "beacon"
    case interest = "interest"
    
    var markerTintColor: UIColor  {
        switch self {
        case .user:
            return .black
        case .station:
            return .red
        case .beacon:
            return .blue
        case .interest:
            return .brown
        }
    }
}

class basicAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let type : basicAnnotationType
    let coordinate: CLLocationCoordinate2D
    let image: String
    
    init(title: String, subtitle: String, type: basicAnnotationType, coordinate: CLLocationCoordinate2D, image: String) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.coordinate = coordinate
        self.image = image
        super.init()
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}

class basicAnnotationHelper {
    
    func constructCustomAnnotation(_ basicAnnotation: basicAnnotation) -> UIView {
        let view = UIView()
        var circleView = CircleView()
        var image = UIImage()

        // Image / Text & Circle construct
        if basicAnnotation.image != "nil" {
            image = PictureManager().decodeStringToImage(image: basicAnnotation.image)
            image = PictureManager().resizeImage(image: image, targetSize: CGSize(width: 30, height: 30))
        } else {
            image = UIImage(named: "username_little")!
            image = PictureManager().resizeImage(image: image, targetSize: CGSize(width: 30, height: 30))
        }
        
        let imageView = imageCircleView(image: image)
        imageView.awakeFromNib()
        imageView.frame = CGRect(x: -13, y: -13, width: imageView.frame.width, height: imageView.frame.height)
        
        circleView = CircleView(frame: CGRect(x: -15.5, y: -15.5, width: imageView.frame.width+5, height: imageView.frame.height+5))
        circleView.backgroundColor = basicAnnotation.type.markerTintColor
        circleView.awakeFromNib()
        
        view.addSubview(circleView)
        view.addSubview(imageView)
        
        // Title message
        let label = UILabel(frame: CGRect(x: -50, y: circleView.frame.size.height/6, width: 100, height: 50))
        
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor: UIColor.white,
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.strokeWidth : -4,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 11)
            ] as [NSAttributedStringKey : Any]
        
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.attributedText = NSMutableAttributedString(string: basicAnnotation.title!, attributes: strokeTextAttributes)
        view.addSubview(label)
        
        return view
    }
}

