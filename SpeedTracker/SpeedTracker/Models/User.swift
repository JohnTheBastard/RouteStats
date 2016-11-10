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

class User {
    static let shared = User()

    private var carRoutes: [Route]{
        didSet{
            save(routeData: self.routes)
        }
    }
    private var bikeRoutes: [Route]{
        didSet{
            save(routeData: self.routes)
        }
    }

    private var runRoutes: [Route]{
        didSet{
            save(routeData: self.routes)
        }
    }

    var routes: [String: [Route]]{
        return [ "carRoutes": self.carRoutes,
                 "bikeRoutes": self.bikeRoutes,
                 "runRoutes": self.runRoutes ]
    }

    private let container: CKContainer
    private let database: CKDatabase

    var routeType: RouteType

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
    private init(){
        print("Trying to initialize from saved data...")
        let defaults = UserDefaults.standard
        var routeData: [String: [Route]]
        if let savedData = defaults.object(forKey: "routeData") as? Data {
            routeData = NSKeyedUnarchiver.unarchiveObject(with: savedData) as! [String: [Route]]
            self.carRoutes  = routeData["carRoutes"]!
            self.bikeRoutes = routeData["bikeRoutes"]!
            self.runRoutes  = routeData["runRoutes"]!
            print("Initialized with saved data!")
        } else {
            self.carRoutes  = []
            self.bikeRoutes = []
            self.runRoutes  = []
        }
        self.container = CKContainer.default()
        self.database = self.container.publicCloudDatabase
        self.routeType = .run
    }

    //MARK: - Public Instance Methods
    func addRoute(route: Route, type: RouteType, completion: RouteDataCompletion) {
        if type == .car {
            self.carRoutes.append(route)
            completion(true)
        } else if type == .bike {
            self.bikeRoutes.append(route)
            completion(true)
        } else if type == .run {
            self.runRoutes.append(route)
            completion(true)
        } else {
            print("Error adding route to user data.")
            completion(false)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fullPath = documentsDirectory.appendingPathComponent("PersistentData")
        return fullPath
    }

    func recordFor(_ savedData: Data) throws -> CKRecord{
        let url = getDocumentsDirectory()
        do{
            try savedData.write(to: url)
            let asset = CKAsset(fileURL: url)
            let record = CKRecord(recordType: "RouteData")
            record.setObject(asset, forKey: "asset")

            return record
        } catch {
            print(error)
            throw error
        }
    }

    func saveToCloud(data: Data, completion: @escaping RouteDataCompletion ) {
        do{
            let record = try recordFor(data)
            self.database.save(record, completionHandler: {(record, error) in
                if error == nil && record != nil {
                    print("Success saving \(record)")
                    OperationQueue.main.addOperation { completion(true) }
                } else {
                    print(error)
                    OperationQueue.main.addOperation { completion(false) }
                }
                
            })
        } catch {
            print(error)
        }
    }

    func save(routeData: [String: [Route]]){
        let savedData = NSKeyedArchiver.archivedData(withRootObject: routeData)
        print(savedData)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "routeData")
        let success = defaults.synchronize()
        print("Route data saved locally? \(success)")

        saveToCloud(data: savedData, completion: { (success) in
                print("Route data saved to cloud? \(success)")
        })
    }
}

