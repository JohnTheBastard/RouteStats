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

    @IBAction func statsSegmentedController(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            print("walking tab opened")

            routesLabel.text = String(User.shared.numberOfRunRoutes)
            averageDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.averageRunDistance)
            totalDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.totalRunDistance)
            averageSpeedLabel.text = Utilities.shared.metersToMiles( 3600 * User.shared.averageRunSpeed)
            totalTimeLabel.text = Utilities.shared.parseTime(User.shared.totalRunElapsedTime)

        case 1:
            print("biking tab opened")

            routesLabel.text = String(User.shared.numberOfBikeRoutes)
            averageDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.averageBikeDistance)
            totalDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.totalBikeDistance)
            averageSpeedLabel.text = Utilities.shared.metersToMiles( 3600 * User.shared.averageBikeSpeed)
            totalTimeLabel.text = String(User.shared.totalBikeElapsedTime)

        case 2:
            print("driving tab opened")

            routesLabel.text = String(User.shared.numberOfCarRoutes)
            averageDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.averageCarDistance)
            totalDistanceLabel.text = Utilities.shared.metersToMiles(User.shared.totalCarDistance)
            averageSpeedLabel.text = Utilities.shared.metersToMiles( 3600 * User.shared.averageCarSpeed)
            totalTimeLabel.text = Utilities.shared.parseTime(User.shared.totalCarElapsedTime)
            
        default:
            break
        }
    }
}
