//
//  RouteViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class RouteViewController: UIViewController {
    @IBOutlet weak var timeTravelled: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness

        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()


    lazy var timer = Timer()
    var elapsedTime: Int = 0
    var distance: Double = 0.0
    lazy var polyline = MKPolyline(coordinates: [], count: 0)
    lazy var allLocations = [CLLocation]()
    var averageVelocity: Double {
        if self.elapsedTime > 0 {
            var temp = self.distance / Double(self.elapsedTime)
            print("\(self.distance) divided by \(self.elapsedTime) equals \(temp)")
            return self.distance / Double(self.elapsedTime)
        } else {
            return 0.0
        }
    }




    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self

        setupLocationManager()

        self.timeTravelled.text = "00:00"
        self.distanceTravelled.text = "0"
        self.currentSpeed.text = "0"
        self.averageSpeed.text = "0"

        //self.view.backgroundColor = UIColor.white
    }

    func setupLocationManager() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestLocation()  //This can probably go away
        }

    }

    func leftPad(_ number: Int) -> String{
        var stringified = String(number)
        if stringified.characters.count < 2 {
            stringified = "0" + stringified
        }
        return stringified
    }

    func parseTime(_ time: Int) -> String{
        //TODO: Think of better variable names
        let mmss = time % 3600           // mod away completed hours for minutes and seconds.
        let hh = (time - mmss) / 3600    // calculate completed hours.
        let ss = time % 60               // mod away completed minutes for seconds.
        let mm = (mmss - ss) / 60        // calculate completed minutes

        var timeString = leftPad(mm) + ":" + leftPad(ss)
        if hh > 0 {
            timeString = leftPad(hh) + ":" +  timeString
        }
        return timeString
    }

    func metersToMiles(distance: Double) -> String{
        // There are 1609.344 meters in a mile
        let miles = distance / 1609.344
        return String(format: "%.2f", miles)

    }

    func locationIsValid(new: CLLocation?, old: CLLocation) -> Bool {
        if  new == nil, new!.horizontalAccuracy < 0 {
                return false
        }


        return true
    }

    func mapRegion() -> MKCoordinateRegion? {
        if let initialLoc = self.allLocations.first?.coordinate {

            var minLat = initialLoc.latitude
            var minLng = initialLoc.longitude
            var maxLat = minLat
            var maxLng = minLng

            let locations = self.allLocations.map({$0.coordinate})

            for location in locations {
                minLat = min(minLat, location.latitude)
                minLng = min(minLng, location.longitude)
                maxLat = max(maxLat, location.latitude)
                maxLng = max(maxLng, location.longitude)
            }

            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                               longitude: (minLng + maxLng)/2),
                span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.75,
                                       longitudeDelta: (maxLng - minLng)*1.75))
        } else {
            return nil
        }
    }

    func setupPolyline() {

        var coords = self.allLocations.map({CLLocationCoordinate2D(latitude: $0.coordinate.latitude,
                                                                   longitude: $0.coordinate.longitude)})
        self.polyline = MKPolyline(coordinates: &coords, count: coords.count)
    }

    func loadMap() {
        if self.allLocations.count > 0 {
            self.mapView.isHidden = false

            self.mapView.region = mapRegion()!

            // Make the line(s!) on the map
            setupPolyline()
            self.mapView.add(self.polyline)
        } else {
            // No locations were found!
            self.mapView.isHidden = true

            print("Error: no locations saved.")
        }
    }

    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }

    func timerRunning() {
        self.elapsedTime += 1
        self.timeTravelled.text = parseTime(self.elapsedTime)

        guard let newLocation = self.locationManager.location else {
            print("Failed to create new location")
            return
        }
        //self.allLocations.append(newLocation)

        self.currentSpeed.text = metersToMiles(distance: newLocation.speed*3600)
        self.distanceTravelled.text = metersToMiles(distance: self.distance)
        self.averageSpeed.text = metersToMiles(distance: self.averageVelocity*3600)
        loadMap()
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        self.timer.invalidate()
        self.allLocations = []
        mapView.remove(self.polyline)
        self.polyline = MKPolyline(coordinates: [], count: 0)
        self.elapsedTime = 0
        self.distance = 0.0

//        guard let startLocation = self.locationManager.location else {
//            //TODO: Alert user that location services not working
//            print("Failed to create start location")
//            return
//        }

        //allLocations = [startLocation]       //How do I validate my first location?

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                          selector: #selector(RouteViewController.timerRunning),
                                          userInfo: nil, repeats: true)
        startLocationUpdates()
    }

    @IBAction func stopButtonPressed(_ sender: Any) {
        self.timer.invalidate()
        //TODO: call to cache route stats needs to go here
    }
}

extension RouteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 8.0

        return renderer
    }

}

extension RouteViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.mapView.showsUserLocation = (status == .authorizedAlways)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.allLocations.count > 0 {
                    self.distance += location.distance(from: self.allLocations.last!)
                }

                //save location
                self.allLocations.append(location)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}









