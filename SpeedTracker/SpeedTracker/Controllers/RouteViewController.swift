//
//  RouteViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn and Jake Dobson on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class RouteViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var timeTravelled: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    let green = UIColor(red:0.15, green:0.50, blue:0.01, alpha:1.0)
    let red = UIColor(red:0.50, green:0.00, blue:0.00, alpha:1.0)
    let grayedOut = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)

    override var prefersStatusBarHidden: Bool {
        return true
    }

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            _locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            //This seems to help reduce bad initial location values.
            _locationManager.requestLocation()
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if User.shared.routeType == .run || User.shared.routeType == .bike {
            _locationManager.activityType = .fitness
            _locationManager.distanceFilter = 10.0
        } else {
            _locationManager.activityType = .automotiveNavigation
            _locationManager.distanceFilter = 20.0
        }
        // Movement threshold for new events
        return _locationManager
    }()

    var locationManagerTimeStamp = Date.distantFuture.timeIntervalSince1970
    var elapsedTime: Int = 0
    var distance: Double = 0.0
    var averageVelocity: Double {
        if self.elapsedTime > 0 {
            return self.distance / Double(self.elapsedTime)
        } else {
            return 0.0
        }
    }

    lazy var allLocations = [CLLocation]()
    lazy var timer = Timer()
    lazy var polyline = MKPolyline(coordinates: [], count: 0)

    // MARK: - ViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIApplication.shared.statusBarStyle = .lightContent
        self.mapView.delegate = self

        self.timeTravelled.text = "00:00"
        self.distanceTravelled.text = "0"
        self.currentSpeed.text = "0"
        self.averageSpeed.text = "0"

        if let statsVC = self.parent?.childViewControllers[1] as? StatsViewController {
            statsVC.segmentedControl.isEnabled = true
        }
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
        self.stopButton.backgroundColor = grayedOut
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetProperties()
        self.locationManager.stopUpdatingLocation()
    }


    private func mapRegion() -> MKCoordinateRegion? {
        if let initialLoc = self.allLocations.first?.coordinate {

            var minLat = initialLoc.latitude
            var minLng = initialLoc.longitude
            var maxLat = minLat
            var maxLng = minLng

            for location in self.allLocations {
                minLat = min(minLat, location.coordinate.latitude)
                minLng = min(minLng, location.coordinate.longitude)
                maxLat = max(maxLat, location.coordinate.latitude)
                maxLng = max(maxLng, location.coordinate.longitude)
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

    private func setupPolyline() {
        var coords = self.allLocations
                         .map({CLLocationCoordinate2D(latitude: $0.coordinate.latitude,
                                                      longitude: $0.coordinate.longitude)})
        self.polyline = MKPolyline(coordinates: &coords, count: coords.count)
    }

    private func loadMap() {
        if self.allLocations.count > 0 {
            self.mapView.isHidden = false
            self.mapView.region = mapRegion()!
            setupPolyline()
            self.mapView.add(self.polyline)
        } else {
            // No locations were found!
            self.mapView.isHidden = true

            print("Error: no locations saved.")
        }
    }

    private func resetProperties(){
        self.timer.invalidate()
        self.allLocations = []
        mapView.remove(self.polyline)
        self.polyline = MKPolyline(coordinates: [], count: 0)
        self.locationManagerTimeStamp = Date.distantFuture.timeIntervalSince1970
        self.elapsedTime = 0
        self.distance = 0.0
    }

    // MARK: - Public Instance Methods
    func timerRunning() {
        self.elapsedTime += 1
        self.timeTravelled.text = Utilities.shared.parseTime(self.elapsedTime)

        guard let currentLocation = self.allLocations.last else {
            print("Failed to find current location")
            return
        }

        self.currentSpeed.text = Utilities.shared.metersToMiles(currentLocation.speed * 3600)
        self.distanceTravelled.text = Utilities.shared.metersToMiles(self.distance)
        self.averageSpeed.text = Utilities.shared.metersToMiles(self.averageVelocity * 3600)
        loadMap()
    }

    func locationIsValid(new: CLLocation?, old: CLLocation) -> Bool {
        if new != nil, new!.horizontalAccuracy >= 0, new!.horizontalAccuracy <= 10{
            let timeSinceLastUpdate = new!.timestamp.timeIntervalSince1970 - old.timestamp.timeIntervalSince1970
            let timeSinceUpdatesStarted = new!.timestamp.timeIntervalSince1970 - self.locationManagerTimeStamp

            if timeSinceLastUpdate > 0, timeSinceUpdatesStarted > 0{
                    return true
            }
        }

        return false
    }

    func toggleButtons() {
        if let statsVC = self.parent?.childViewControllers[1] as? StatsViewController {
            statsVC.segmentedControl.isEnabled = !statsVC.segmentedControl.isEnabled
        }

        if self.startButton.isEnabled {
            self.startButton.backgroundColor = grayedOut
            self.startButton.isEnabled = false
        } else {
            self.startButton.backgroundColor = green
            self.startButton.isEnabled = true
        }

        if self.stopButton.isEnabled {
            self.stopButton.backgroundColor = grayedOut
            self.stopButton.isEnabled = false
        } else {
            self.stopButton.backgroundColor = red
            self.stopButton.isEnabled = true
        }
    }

    // MARK: - Actions

    @IBAction func startButtonPressed(_ sender: Any) {
        resetProperties()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                          selector: #selector(RouteViewController.timerRunning),
                                          userInfo: nil, repeats: true)
        self.locationManagerTimeStamp = Date().timeIntervalSince1970
        self.locationManager.startUpdatingLocation()

        self.toggleButtons()
    }

    @IBAction func stopButtonPressed(_ sender: Any) {
        self.timer.invalidate()

        let completedRoute = Route(timeElapsed: self.elapsedTime,
                                   distanceTravelled: self.distance,
                                   locations: self.allLocations)

        User.shared.addRoute(route: completedRoute, type: User.shared.routeType, completion: { (success) in
            if success {
                print("Route data saved!")
            } else {
                print("There was an error attempting to save route data.")
            }

        })

        self.toggleButtons()

    }

    @IBAction func swipeGestureRecognizer(_ sender: Any) {
        print("swiper is swiping")
        self.dismiss(animated: true)
    }


}

// MARK: - Protocol Extensions
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
            if self.allLocations.count > 1, locationIsValid(new: location, old: self.allLocations.last!) {
                self.distance += location.distance(from: self.allLocations.last!)
                self.allLocations.append(location)
            } else if self.allLocations.count <= 1,
                      location.horizontalAccuracy >= 0,
                      location.horizontalAccuracy <= 10 {
                self.allLocations.append(location)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}









