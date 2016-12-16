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

enum ButtonColor {
    case green, red
}


class RouteViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var timeTravelled: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var routeButtonImage: UIImageView!
    var routeButtonState: ButtonColor = .green

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

        mapView.delegate = self

        setupView()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetProperties()
        locationManager.stopUpdatingLocation()
    }


    private func setupView() {
        timeTravelled.text = "00:00"
        distanceTravelled.text = "0"
        currentSpeed.text = "0"
        averageSpeed.text = "0"

        if let statsVC = self.parent?.childViewControllers[1] as? StatsViewController {
            statsVC.segmentedControl.isEnabled = true
        }

        routeButton.isEnabled = true
        routeButtonImage.image = routeButtonImage.image!.withRenderingMode(.alwaysTemplate)
        routeButtonImage.tintColor = green
    }

    private func mapRegion() -> MKCoordinateRegion? {
        if let initialLoc = allLocations.first?.coordinate {

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
        var coords = allLocations
                         .map({CLLocationCoordinate2D(latitude: $0.coordinate.latitude,
                                                      longitude: $0.coordinate.longitude)})
        polyline = MKPolyline(coordinates: &coords, count: coords.count)
    }

    private func loadMap() {
        if allLocations.count > 0 {
            mapView.isHidden = false
            mapView.region = mapRegion()!
            setupPolyline()
            mapView.add(self.polyline)
        } else {
            // No locations were found!
            mapView.isHidden = true

            print("Error: no locations saved.")
        }
    }

    private func resetProperties(){
        timer.invalidate()
        allLocations = []
        mapView.remove(polyline)
        polyline = MKPolyline(coordinates: [], count: 0)
        locationManagerTimeStamp = Date.distantFuture.timeIntervalSince1970
        elapsedTime = 0
        distance = 0.0
    }

    private func beginRoute() {
        resetProperties()
        User.shared.currentRoute = .active
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(RouteViewController.timerRunning),
                                     userInfo: nil, repeats: true)
        locationManagerTimeStamp = Date().timeIntervalSince1970
        locationManager.startUpdatingLocation()
    }

    private func endRoute() {
        timer.invalidate()
        User.shared.currentRoute = .inactive
        let completedRoute = Route(timeElapsed: elapsedTime,
                                   distanceTravelled: distance,
                                   locations: allLocations)

        User.shared.addRoute(route: completedRoute, type: User.shared.routeType, completion: { (success) in
            if success {
                print("Route data saved!")
            } else {
                print("There was an error attempting to save route data.")
            }

        })
    }

    private func toggleButtons() {
        if let statsVC = self.parent?.childViewControllers[1] as? StatsViewController {
            statsVC.segmentedControl.isEnabled = !statsVC.segmentedControl.isEnabled
        }
        switch routeButtonState {

        case .green:
            routeButtonState = .red
            routeButtonImage.tintColor = red
            routeButton.setTitle("End Route", for: .normal)
        case .red:
            routeButtonState = .green
            routeButtonImage.tintColor = green
            routeButton.setTitle("Begin New Route", for: .normal)
        }
        
    }

    // MARK: - Public Instance Methods
    func timerRunning() {
        elapsedTime += 1
        timeTravelled.text = Utilities.shared.parseTime(elapsedTime)

        guard let currentLocation = allLocations.last else {
            print("Failed to find current location")
            return
        }

        currentSpeed.text = Utilities.shared.metersToMiles(currentLocation.speed * 3600)
        distanceTravelled.text = Utilities.shared.metersToMiles(distance)
        averageSpeed.text = Utilities.shared.metersToMiles(averageVelocity * 3600)
        loadMap()
    }

    func locationIsValid(new: CLLocation?, old: CLLocation) -> Bool {
        if new != nil, new!.horizontalAccuracy >= 0, new!.horizontalAccuracy <= 10{
            let timeSinceLastUpdate = new!.timestamp.timeIntervalSince1970 - old.timestamp.timeIntervalSince1970
            let timeSinceUpdatesStarted = new!.timestamp.timeIntervalSince1970 - locationManagerTimeStamp

            if timeSinceLastUpdate > 0, timeSinceUpdatesStarted > 0{
                    return true
            }
        }

        return false
    }


    // MARK: - Actions
    @IBAction func routeButtonPressed(_ sender: UIButton) {
        switch routeButtonState {
            case .green: beginRoute()
            case .red: endRoute()
        }
        toggleButtons()
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
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        self.mapView.showsUserLocation = (status == .authorizedAlways)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if allLocations.count > 1, locationIsValid(new: location, old: allLocations.last!) {
                distance += location.distance(from: allLocations.last!)
                allLocations.append(location)
            } else if allLocations.count <= 1,
                      location.horizontalAccuracy >= 0,
                      location.horizontalAccuracy <= 10 {
                allLocations.append(location)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}









