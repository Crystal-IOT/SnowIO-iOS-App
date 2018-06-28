//
//  StationModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class StationModel: Mappable {
    var name: String!
    var phone: String!
    var position : PositionModel!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.name <- map["name"]
        self.phone <- map["phone"]
        self.position <- map["position"]
    }
    
    var description:[String:Any] {
        get {
            return [
                "name": name,
                "phone": phone,
                "position" : position
                ] as [String : Any]
        }
    }
}
