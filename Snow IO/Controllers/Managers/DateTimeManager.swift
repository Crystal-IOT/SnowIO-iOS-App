//
//  DateTimeManager.swift
//  Snow IO
//
//  Created by Steven F. on 05/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class DateTimeManager {
    
    // Get Formatted Date
    func getFormattedDate(numberInHours: CLong) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier:"GMT")
        
        let myDateLong = numberInHours * 3600

        if(AppDelegate.language != "fr") {
            dateFormatter.dateFormat = "HH:mm a"
            let date = Date(timeIntervalSince1970: TimeInterval(myDateLong))
            let timeStamp = dateFormatter.string(from: date as Date)
            return timeStamp
        }
        else {
            dateFormatter.dateFormat = "HH'h'mm"
            let date = Date(timeIntervalSince1970: TimeInterval(myDateLong))
            let timeStamp = dateFormatter.string(from: date as Date)
            return timeStamp
        }
    }
}
