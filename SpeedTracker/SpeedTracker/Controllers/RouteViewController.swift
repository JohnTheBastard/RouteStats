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

    let locationManager = CLLocationManager()
    var timer = Timer()
    var elapsedTime = 0
    var startLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self

        setupLocationManager()

        self.timeTravelled.text = "foo"
        self.distanceTravelled.text = "bar"

        //self.view.backgroundColor = UIColor.white
    }

    func setupLocationManager() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }

    }
    func parseTime(_ seconds: Int) -> String{
        //TODO: Make this readable
        let mmss = seconds % 3600
        let hh = (seconds - mmss) / 3600
        let ss = seconds % 60
        let mm = (mmss - ss) / 60

        //TODO: Clean this up with flow control
        return "\(hh):\(mm):\(ss)"

    }

    func milesPerHour(_ metersPerSecond: Double) -> Double {
        return metersPerSecond * 2.2369363
    }

    func timerRunning() {
        startLocation = locationManager.location
        elapsedTime += 1
        timeTravelled.text = parseTime(elapsedTime)
//        var speedInMetersPerSecond = CLLocationSpeed()
//        speedInMetersPerSecond = (locationManager.location?.speed)!
//        currentSpeed.text = String(milesPerHour(speedInMetersPerSecond))
        let temp = locationManager.location?.speed
        currentSpeed.text = "\(temp!)"
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        timer.invalidate()
        elapsedTime = 0


        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(RouteViewController.timerRunning),
                                      userInfo: nil, repeats: true)
    }

    @IBAction func stopButtonPressed(_ sender: Any) {
        timer.invalidate()
    }



}

extension RouteViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
}
