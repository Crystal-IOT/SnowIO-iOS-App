//
//  UserModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class UserModel: Mappable {
    var idProfil : Int!
    var email: String!
    var firstname: String!
    var lastname: String!
    var phone: String!
    var picture: String!
    var position: PositionModel!
    
    init() {
    }
    
    init(idProfil: Int, email: String, firstname: String, lastname: String, phone: String, picture: String, position: PositionModel) {
        self.idProfil = idProfil
        self.email = email
        self.firstname = firstname
        self.lastname = lastname
        self.phone = phone
        self.picture = picture
        self.position = position
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.idProfil <- map["idProfil"]
        self.email <- map["email"]
        self.firstname <- map["firstname"]
        self.lastname <- map["lastname"]
        self.phone <- map["phone"]
        self.picture <- map["picture"]
        self.position <- map["position"]
    }
    
    var description:[String:Any] {
        get {
            return [
                "idProfil": idProfil,
                /*"email": email,*/
                "firstname" : firstname,
                "lastname" : lastname,
                "phone" : phone,
                "picture" : picture,
                "position" : position.description
                ] as [String : Any]
        }
    }
}
