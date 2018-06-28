//
//  PositionModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class PositionModel: Mappable {
    var latitude: Double!
    var longitude: Double!
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
    }
    
    var description:[String:Any] {
        get {
            return [
                "latitude": latitude,
                "longitude": longitude
                ] as [String : Any]
        }
    }
}
