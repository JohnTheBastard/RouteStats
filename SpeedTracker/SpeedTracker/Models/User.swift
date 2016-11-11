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

        print("Looking for cloud data...")
        var cloudRoutes = [String: [Route]]()
        fetchFromCloud( completion: { (routes) in
            if let routes = routes {
                cloudRoutes = routes
            } else {
                print("Error: no data in the cloud!")
            }
        })
        print("\(cloudRoutes)")
    }

    //MARK: - Public Instance Methods

    func computeStatsFor(type: RouteType) -> [String: Double] {
        var routes: [Route]

        switch type{
            case .run:  routes = self.runRoutes
            case .bike: routes = self.bikeRoutes
            case .car:  routes = self.carRoutes
        }

        let numberOfRoutes = routes.count
        let totalElapsedTime = routes.reduce(0){ (result, route) in
            result + route.timeElapsed
        }
        let totalDistance = routes.reduce(0.0){ (result, route) in
            result + route.distanceTravelled
        }
        let averageSpeed = totalDistance / Double( totalElapsedTime )
        let averageDistance = totalDistance / Double(numberOfRoutes)
        print("totalElapsedTime: \(totalElapsedTime)\nnumberOfRoutes: \(numberOfRoutes) ")

        var averageElapsedTime: Double{
            if numberOfRoutes == 0 {
                return 0.0
            } else {
                return Double(totalElapsedTime / numberOfRoutes)
            }
        }

        let stats =
            [ "numberOfRoutes":     Double(numberOfRoutes),
              "totalElapsedTime":   Double(totalElapsedTime),
              "totalDistance":      totalDistance,
              "averageSpeed":       averageSpeed,
              "averageDistance":    averageDistance,
              "averageElapsedTime": averageElapsedTime ]

        return stats
    }

    func addRoute(route: Route, type: RouteType, completion: RouteDataCompletion) {
        switch type{
            case .run:  self.runRoutes.append(route);  completion(true)
            case .bike: self.bikeRoutes.append(route); completion(true)
            case .car:  self.carRoutes.append(route);  completion(true)
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

    func fetchFromCloud(completion: @escaping GetRouteDataCompletion) {
        let query = CKQuery(recordType: "routeData", predicate: NSPredicate(value: true) )
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        query.sortDescriptors = [sortDescriptor]

        self.database.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                if let records = records{
                    var fetchedData = [ [String:[Route]] ]()
                    for record in records{
                        print("Creation Date: \(record.creationDate?.description)")
                    }
                    if records.count > 1 {
                        let queue = OperationQueue()
                        for ii in 0..<records.count-1 {
                            let operation = {
                                self.database.delete(withRecordID: records[ii].recordID,
                                                     completionHandler: { (recordID, error) in
                                print(error)
                                })
                            }
                            queue.addOperation(operation)
                        }
                    }

                    guard let asset = records.last?["asset"] as? CKAsset else { return }

                    let url = asset.fileURL
                    do{
                        let routeData = try Data(contentsOf: url)

                        fetchedData.append( NSKeyedUnarchiver.unarchiveObject(with: routeData) as! [String : [Route]] )

                    } catch {
                        print(error)
                        return
                    }
                    OperationQueue.main.addOperation { completion(fetchedData.last) }
                }
            } else {
                print(error)
            }
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

