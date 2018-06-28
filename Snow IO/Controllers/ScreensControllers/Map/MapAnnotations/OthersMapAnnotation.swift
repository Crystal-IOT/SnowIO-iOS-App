//
//  MapAnnotationManager.swift
//  Snow IO
//
//  Created by Steven F. on 11/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import MapKit
import Pulsator


private let userStationCycleClusterID = "userStationCycle"
private let stationInfoCycleClusterID = "stationInformationCycle"


// MARK : - basicUserAnnotationView
class basicUserAnnotationView: MKAnnotationView {
    
    static let reuseID = "basicUserAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = userStationCycleClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? basicAnnotation else { return }
           
            // Setup
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -10)
            displayPriority = .defaultHigh
            
            // Disclosure Button
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "maps_icon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
            
            // Customize View
            self.addSubview(basicAnnotationHelper().constructCustomAnnotation(annotation))
        }
    }
}

// MARK : - basicStationAnnotationView
class basicStationAnnotationView: MKMarkerAnnotationView {
    
    static let reuseID = "basicStationAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = userStationCycleClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? basicAnnotation else { return }
            
            // Setup
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
            displayPriority = .defaultHigh
            
            // Disclosure Button
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "maps_icon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
   
            // Customize
            glyphText = String(annotation.type.rawValue.uppercased().first!)
            markerTintColor = annotation.type.markerTintColor
        }
    }
}

// MARK : - basicInterestAnnotationView
class basicInterestAnnotationView: MKAnnotationView {
    
    static let reuseID = "basicInterestAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = stationInfoCycleClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? basicAnnotation else { return }
            
            // Setup
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -10)
            displayPriority = .defaultLow
            
            // Disclosure Button
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "maps_icon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
            
            // Customize View
            self.addSubview(basicAnnotationHelper().constructCustomAnnotation(annotation))
        }
    }
}

// MARK : - basicBeaconAnnotationView
class basicBeaconAnnotationView : MKAnnotationView {
    
    static let reuseID = "basicBeaconAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = stationInfoCycleClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            
            // Setup
            guard let annotation = newValue as? basicAnnotation else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
            displayPriority = .defaultLow
            
            // Customize
            let pulsator = Pulsator()
            pulsator.position = center
            pulsator.numPulse = 5
            pulsator.radius = 30
            pulsator.animationDuration = 5
            pulsator.backgroundColor = annotation.type.markerTintColor.cgColor
            layer.addSublayer(pulsator)
            pulsator.start()
        }
    }
}
