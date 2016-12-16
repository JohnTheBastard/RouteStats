//
//  Utilities.swift
//  RouteStats
//
//  Created by John D Hearn on 11/10/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import Foundation


class Utilities {
    static let shared = Utilities()

    private init() {}

    func leftPad(_ number: Int) -> String{
        var stringified = String(number)
        if stringified.characters.count < 2 {
            stringified = "0" + stringified
        }
        return stringified
    }

    func parseTime(_ time: Int) -> String{
        let mmss = time % 3600           // mod away completed hours for minutes and seconds.
        var hh = (time - mmss) / 3600    // calculate completed hours.
        let ss = time % 60               // mod away completed minutes for seconds.
        let mm = (mmss - ss) / 60        // calculate completed minutes

        // Let's get days, too, while we're at it.
        var dd = 0
        if hh > 24 {
            let temp = hh % 24
            dd = (hh - temp) / 24
            hh = temp
        }

        var timeString = self.leftPad(mm) + ":" + self.leftPad(ss)
        if hh > 0 {
            timeString = self.leftPad(hh) + ":" +  timeString
        }
        if dd > 0 {
            timeString = self.leftPad(dd) + ":" +  timeString
        }
        return timeString
    }

    func metersToMiles(_ distance: Double) -> String{
        let metersInAMile = 1609.344
        let miles = distance / metersInAMile
        return String(format: "%.2f", miles)

    }

}
