//
//  SkiSlopeModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class SkiSlopeModel: Mappable {
    var idStation: String!
    var level: Int!
    var name: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.idStation <- map["idStation"]
        self.level <- map["idLevel"]
        self.name <- map["name"]
    }
    
    var description:[String:Any] {
        get {
            return [
                "idStation": idStation,
                "level": level,
                "name" : name
                ] as [String : Any]
        }
    }
}

class SkiSlopeLevel: Mappable {
    var name: String!
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.name <- map["name"]
    }
    
    var description:[String:Any] {
        get {
            return [
                "name": name
                ] as [String : Any]
        }
    }
}

