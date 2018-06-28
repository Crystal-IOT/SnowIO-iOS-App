//
//  UserProfileModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class ProfileModel: Mappable {
    var name: String!
    
    init() {
    }
    
    init(name: String) {
        self.name = name
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
