//
//  Route.swift
//  SpeedTracker
//
//  Created by John D Hearn and Jake Dobson on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import Foundation
import CoreLocation

enum RouteType {
    case car, bike, run
}

class Route {
    var timeElapsed: Int
    var distanceTravelled: Double
    var averageSpeed: Double {
        return 3600 * distanceTravelled/(Double(timeElapsed))
    }
    var locations: [CLLocation]

    init(){
        self.timeElapsed = 0
        self.distanceTravelled = 0.0
        self.locations = []
    }

    init(timeElapsed: Int, distanceTravelled: Double, locations: [CLLocation]){
        self.timeElapsed = timeElapsed
        self.distanceTravelled = distanceTravelled
        self.locations = locations
    }
}
