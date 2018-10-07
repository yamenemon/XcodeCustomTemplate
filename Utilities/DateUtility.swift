//
//  DateUtility.swift
//  Energieq
//
//  Created by Binate on 22/5/18.
//  Copyright © 2018 Shah Yasin. All rights reserved.
//

import UIKit

class DateUtility: NSObject {
    class func getDateFromDateString(_ date: String?, fromFormat from: String?, toFormat to: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = from
        let pickedDate: Date? = dateFormatter.date(from: date!)
        dateFormatter.dateFormat = to
        dateFormatter.timeZone = TimeZone.current
        var pickedDateString: String? = nil
        if let aDate = pickedDate {
            pickedDateString = dateFormatter.string(from: aDate)
        }
        return pickedDateString
        
    }
}
