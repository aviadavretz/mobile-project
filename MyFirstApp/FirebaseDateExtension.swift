//
// Created by admin on 10/03/2017.
// Copyright (c) 2017 Naveh Ohana. All rights reserved.
//

import Foundation

extension NSDate {

    func toFirebase()->Double{
        return self.timeIntervalSince1970 * 1000
    }

    static func fromFirebase(_ interval:String)->NSDate{
        return fromFirebasee(Double(interval)!)
    }

    static func fromFirebasee(_ interval:Double)->NSDate{
        return NSDate(timeIntervalSince1970: interval/1000)
    }
}
