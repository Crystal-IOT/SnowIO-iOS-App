//
//  BeaconModel.swift
//  Snow IO
//
//  Created by Steven F. on 08/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class BeaconModel: Mappable {
    var beaconPlacement : String?
    var idSkiSlope: String!
    var major: Int!
    var minor: Int!
    var name: String!
    var beaconID: String!
    var beaconPosition: PositionModel!
   
    
    init(beaconPlacement: String, idSkiSlope: String, major: Int, minor: Int, name: String, beaconID: String, beaconPosition: PositionModel) {
        self.beaconPlacement = beaconPlacement
        self.idSkiSlope = idSkiSlope
        self.major = major
        self.minor = minor
        self.name = name
        self.beaconID = beaconID
        self.beaconPosition = beaconPosition
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        self.beaconPlacement <- map["SkiSlopePosition"]
        self.idSkiSlope <- map["idSkiSlope"]
        self.major <- map["major"]
        self.minor <- map["minor"]
        self.name <- map["name"]
        self.beaconID <- map["uuid"]
        self.beaconPosition <- map["position"]
    }}
