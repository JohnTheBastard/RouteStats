//
//  ContainerViewController.swift
//  RouteStats
//
//  Created by John D Hearn on 12/14/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

enum StatsViewPosition {
    case up, down
}

class ContainerViewController: UIViewController {

    var upFrame: CGRect {
        return CGRect(x: 0.0,
                      y: -self.view.frame.size.height + 52,
                      width: self.view.frame.size.width,
                      height: self.view.frame.size.height)
    }

    var downFrame: CGRect {
        return CGRect(x: 0.0,
                      y: -160,
                      width: self.view.frame.size.width,
                      height: self.view.frame.size.height)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    var cachedSegmentSelection = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChild( RouteViewController(nibName: "RouteViewController", bundle: nil) )
        setupChild( StatsViewController(nibName: "StatsViewController", bundle: nil))
        print(self.childViewControllers)

        slideStatsVC()


    }

    func setupChild(_ viewController: UIViewController) {
        viewController.view.frame = self.view.frame
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }

    func slideStatsVC() {
        if let statsVC = childViewControllers[1] as? StatsViewController {
            //statsVC.statsTableView.reloadData()
            switch User.shared.statsViewPosition {
            case .up:
                UIView.animate(withDuration: 0.4, animations: {
                    if User.shared.currentRoute == .active{
                        self.cachedSegmentSelection = statsVC.segmentedControl.selectedSegmentIndex
                        statsVC.segmentedControl.isEnabled = true
                    }
                    statsVC.view.frame = self.downFrame
                    User.shared.statsViewPosition = .down
                }, completion: nil)
            case .down:
                UIView.animate(withDuration: 0.4, animations: {
                    if User.shared.currentRoute == .active{
                        statsVC.segmentedControl.selectedSegmentIndex = self.cachedSegmentSelection
                        statsVC.segmentedControl.isEnabled = false
                    }
                    self.childViewControllers[1].view.frame = self.upFrame
                    User.shared.statsViewPosition = .up
                }, completion: nil)
            }
        }
    }
}
