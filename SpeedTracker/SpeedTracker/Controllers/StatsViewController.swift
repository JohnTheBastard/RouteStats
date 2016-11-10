//
//  StatsViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    
    @IBOutlet weak var routesLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func statsSegmentedController(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            print("walking tab opened")

            routesLabel.text = String(User.shared.numberOfRunRoutes)
            averageDistanceLabel.text = String(User.shared.averageRunDistance)
            totalDistanceLabel.text = String(User.shared.totalRunDistance)
            averageSpeedLabel.text = String(User.shared.averageRunSpeed)
            totalTimeLabel.text = String(User.shared.totalRunElapsedTime)

        case 1:
            print("biking tab opened")

            routesLabel.text = String(User.shared.numberOfBikeRoutes)
            averageDistanceLabel.text = String(User.shared.averageBikeDistance)
            totalDistanceLabel.text = String(User.shared.totalBikeDistance)
            averageSpeedLabel.text = String(User.shared.averageBikeSpeed)
            totalTimeLabel.text = String(User.shared.totalBikeElapsedTime)

        case 2:
            print("driving tab opened")

            routesLabel.text = String(User.shared.numberOfCarRoutes)
            averageDistanceLabel.text = String(User.shared.averageCarDistance)
            totalDistanceLabel.text = String(User.shared.totalCarDistance)
            averageSpeedLabel.text = String(User.shared.averageCarSpeed)
            totalTimeLabel.text = String(User.shared.totalCarElapsedTime)
            
        default:
            break
        }
    }
}
