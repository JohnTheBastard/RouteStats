//
//  StatsViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var routesLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //segmentedControl.contentMode = UIViewContentMode.scaleToFill
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func statsSegmentedController(_ sender: Any) {
        var routeType: RouteType
        switch (sender as AnyObject).selectedSegmentIndex {
            case 0: routeType = .run
            case 1: routeType = .bike
            case 2: routeType = .car
            default:
                routeType = User.shared.routeType  // this is never hit, just needed to "guarantee" initialization
                break
        }

        let stats = User.shared.computeStatsFor(type: routeType)
        let routeCount = Int(stats["numberOfRoutes"]!)

        routesLabel.text = "\(routeCount)"
        averageDistanceLabel.text = Utilities.shared.metersToMiles( stats["averageDistance"]! )
        totalDistanceLabel.text = Utilities.shared.metersToMiles( stats["totalDistance"]! )
        averageSpeedLabel.text = Utilities.shared.metersToMiles( 3600 * stats["averageSpeed"]!)
        totalTimeLabel.text = Utilities.shared.parseTime( Int(stats["totalElapsedTime"]!) )
    }
}
