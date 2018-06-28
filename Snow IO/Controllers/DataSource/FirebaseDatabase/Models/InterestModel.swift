//
//  InterestModel.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import ObjectMapper

class InterestCategorie: Mappable {
    var image: String!
    var name: String!
    //var nameTranslation: TranslationModel!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.image <- map["image"]
        self.name <- map["name"]
        //self.nameTranslation <- map[""]
    }
}

class InterestModel: Mappable {
    var image: String!
    var longDescription: String!
    var idStation: Int!
    var name: String!
    var phone: String!
    var position: PositionModel!
    var hours: Schedule!
    
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.image <- map["image"]
        self.longDescription <- map["description"]
        self.hours <- map["schedule"]
        self.idStation <- map["idStation"]
        self.name <- map["name"]
        self.phone <- map["phone"]
        self.position <- map["position"]
    }
}

class Schedule: Mappable {
    var monday: ScheduleHours!
    var tuesday: ScheduleHours!
    var wednesday: ScheduleHours!
    var thursday: ScheduleHours!
    var friday: ScheduleHours!
    var saturday: ScheduleHours!
    var sunday: ScheduleHours!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.monday <- map["Monday"]
        self.tuesday <- map["Tuesday"]
        self.wednesday <- map["Wednesday"]
        self.thursday <- map["Thursday"]
        self.friday <- map["Friday"]
        self.saturday <- map["Saturday"]
        self.sunday <- map["Sunday"]
    }
}

class ScheduleHours: Mappable {
    var beginHour: CLong!
    var endHour: CLong!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.beginHour <- map["begin"]
        self.endHour <- map["end"]
    }
}
