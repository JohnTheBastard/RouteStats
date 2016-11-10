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

class Route: NSObject {
    var timeElapsed: Int
    var distanceTravelled: Double
    var averageSpeed: Double {
        return 3600 * distanceTravelled/(Double(timeElapsed))
    }
    var locations: [CLLocation]

    override init(){
        self.timeElapsed = 0
        self.distanceTravelled = 0.0
        self.locations = []
    }

    init(timeElapsed: Int, distanceTravelled: Double, locations: [CLLocation]){
        self.timeElapsed = timeElapsed
        self.distanceTravelled = distanceTravelled
        self.locations = locations
    }

    required init?(coder aDecoder: NSCoder) {
        print("\(aDecoder)")
        self.timeElapsed = aDecoder.decodeInteger(forKey: "timeElapsed")
        self.distanceTravelled = aDecoder.decodeDouble(forKey: "distanceTravelled")
        self.locations = aDecoder.decodeObject(forKey: "locations") as! [CLLocation]
        super.init()
    }

}

extension Route: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.timeElapsed, forKey: "timeElapsed")
        aCoder.encode(self.distanceTravelled, forKey: "distanceTravelled")
        aCoder.encode(self.locations, forKey: "locations")
    }

}
