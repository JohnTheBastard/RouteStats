//
//  User.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/8/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import Foundation
import CoreLocation


class User{
    private var carRoutes: [Route]
    private var bikeRoutes: [Route]
    private var runRoutes: [Route]

    //MARK: - Computed Properties
    var numberOfCarRoutes: Int {
        return self.carRoutes.count
    }
    var totalCarElapsedTime: Int{
        return self.carRoutes.reduce(0){ (result, route) in
            result + route.timeElapsed
        }
    }
    var totalCarDistance: Double{
        return self.carRoutes.reduce(0.0){ (result, route) in
            result + route.distanceTravelled
        }
    }
    var averageCarSpeed: Double{
        return self.totalCarDistance / Double(self.totalCarElapsedTime)
    }
    var averageCarDistance: Double{
        return self.totalCarDistance / Double(self.carRoutes.count)
    }
    var averageCarElapsedTime: Int{
        return self.totalCarElapsedTime / self.carRoutes.count
    }

    var numberOfBikeRoutes: Int {
        return self.bikeRoutes.count
    }
    var totalBikeElapsedTime: Int{
        return self.bikeRoutes.reduce(0){ (result, route) in
            result + route.timeElapsed
        }
    }
    var totalBikeDistance: Double{
        return self.bikeRoutes.reduce(0.0){ (result, route) in
            result + route.distanceTravelled
        }
    }
    var averageBikeSpeed: Double{
        return self.totalBikeDistance / Double(self.totalBikeElapsedTime)
    }
    var averageBikeDistance: Double{
        return self.totalBikeDistance / Double(self.bikeRoutes.count)
    }
    var averageBikeElapsedTime: Int{
        return self.totalBikeElapsedTime / self.bikeRoutes.count
    }

    var numberOfRunRoutes: Int {
        return self.runRoutes.count
    }
    var totalRunElapsedTime: Int{
        return self.runRoutes.reduce(0){ (result, route) in
            result + route.timeElapsed
        }
    }
    var totalRunDistance: Double{
        return self.runRoutes.reduce(0.0){ (result, route) in
            result + route.distanceTravelled
        }
    }
    var averageRunSpeed: Double{
        return self.totalRunDistance / Double(self.totalRunElapsedTime)
    }
    var averageRunDistance: Double{
        return self.totalRunDistance / Double(self.runRoutes.count)
    }
    var averageRunElapsedTime: Int{
        return self.totalRunElapsedTime / self.runRoutes.count
    }


    //MARK: - Initializers
    init(){
        self.carRoutes  = []
        self.bikeRoutes = []
        self.runRoutes  = []
    }

    //MARK: - Instance Methods
    func addRoute(route: Route, type: RouteType) {
        if type == .car {
            self.carRoutes.append(route)
        } else if type == .bike {
            self.bikeRoutes.append(route)
        } else if type == .run {
            self.runRoutes.append(route)
        }
    }


//    private func averageSpeed(_ routes: [Route])-> Double{
//        let totals = routes.reduce((0.0, 0)){ (result, route) in
//            return (result.0 + route.distanceTravelled,
//                    result.1 + route.timeElapsed)
//        }
//        return totals.0 / Double(totals.1)
//    }
}
