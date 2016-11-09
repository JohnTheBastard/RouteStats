//
//  User.swift
//  SpeedTracker
//
//  Created by John D Hearn and Jake Dobson on 11/8/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit


typealias RouteDataCompletion = (Bool)->()
typealias GetRouteDataCompletion = ([String:[Route]]?)->()


class User: NSObject, NSCoding{
    static let shared = User()

    private var carRoutes: [Route]
    private var bikeRoutes: [Route]
    private var runRoutes: [Route]

    private let container: CKContainer
    private let database: CKDatabase

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
    private override init(){
        self.carRoutes  = []
        self.bikeRoutes = []
        self.runRoutes  = []
        self.container = CKContainer.default()
        self.database = self.container.privateCloudDatabase
    }

    internal required init?(coder aDecoder: NSCoder) {
        self.carRoutes  = aDecoder.decodeObject(forKey: "carRoutes") as! [Route]
        self.bikeRoutes = aDecoder.decodeObject(forKey: "bikeRoutes") as! [Route]
        self.runRoutes  = aDecoder.decodeObject(forKey: "runRoutes") as! [Route]
        self.container = CKContainer.default()
        self.database = self.container.privateCloudDatabase
    }


    //MARK: - Private Methods
//    private func recordFor(_ savedData: Data) throws -> CKRecord? {
//        let dataURL = URL.dataURL()
//
//        //guard let data =
//        return nil
//    }



    //MARK: - Public Instance Methods
    func addRoute(route: Route, type: RouteType) {
        if type == .car {
            self.carRoutes.append(route)
        } else if type == .bike {
            self.bikeRoutes.append(route)
        } else if type == .run {
            self.runRoutes.append(route)
        }
    }

//    func save(routeData: [String: [Route]], completion: @escaping RouteDataCompletion ){
//        do{
//            let savedData = NSKeyedArchiver.archivedData(withRootObject: routeData)
//            let defaults = UserDefaults.standard
//            defaults.set(savedData, forKey: "routeData")
//
//            if let record = try recordFor(savedData) {
//                self.database.save(record, completionHandler: {(record, error) in
//                    if error == nil && record != nil {
//                        print("Success saving \(record)")
//                        completion(true)
//                    }
//                })
//            }
//        } catch {
//            print(error)
//            completion(false)
//        }
//    }

    func encode(with aCoder: NSCoder) {
        // I can't put this method in a protocol extension
        // without making route properties public.
        aCoder.encode(self.carRoutes, forKey: "carRoutes")
        aCoder.encode(self.bikeRoutes, forKey: "bikeRoutes")
        aCoder.encode(self.runRoutes, forKey: "runRoutes")
    }
}

