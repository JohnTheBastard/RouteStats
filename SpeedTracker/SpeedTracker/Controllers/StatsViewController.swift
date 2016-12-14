//
//  StatsViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var statsTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet var statsSectionHeader: UITableViewCell!

    @IBOutlet var routesCell: UITableViewCell!
    @IBOutlet var averageDistanceCell: UITableViewCell!
    @IBOutlet var totalDistanceCell: UITableViewCell!
    @IBOutlet var averageSpeedCell: UITableViewCell!
    @IBOutlet var totalTimeCell: UITableViewCell!

    @IBOutlet weak var routesLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.contentMode = UIViewContentMode.scaleToFill
        //UIApplication.shared.statusBarStyle = .lightContent

        statsTableView.delegate = self
        statsTableView.dataSource = self

        statsTableView.register(UINib(nibName: "StatsViewController", bundle: nil),
                                forHeaderFooterViewReuseIdentifier: "StatsSectionHeader")

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func statsSegmentedController(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
            case 0: User.shared.routeType = .run
            case 1: User.shared.routeType = .bike
            case 2: User.shared.routeType = .car
            default: break
        }

        let stats = User.shared.computeStatsFor(type: User.shared.routeType)
        let routeCount = Int(stats["numberOfRoutes"]!)

        routesLabel.text = "\(routeCount)"
        averageDistanceLabel.text = Utilities.shared.metersToMiles( stats["averageDistance"]! )
        totalDistanceLabel.text = Utilities.shared.metersToMiles( stats["totalDistance"]! )
        averageSpeedLabel.text = Utilities.shared.metersToMiles( 3600 * stats["averageSpeed"]!)
        totalTimeLabel.text = Utilities.shared.parseTime( Int(stats["totalElapsedTime"]!) )
    }
}

extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:  return routesCell
            case 1:  return averageDistanceCell
            case 2:  return totalDistanceCell
            case 3:  return averageSpeedCell
            default: return totalTimeCell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //return tableView.dequeueReusableHeaderFooterView(withIdentifier: "StatsSectionHeader")
        return statsSectionHeader
    }

}
