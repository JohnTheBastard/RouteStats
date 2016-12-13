//
//  SelectionViewController.swift
//  SpeedTracker
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {

    @IBOutlet weak var walkingGlyph: UIImageView!
    @IBOutlet weak var bicycleGlyph: UIImageView!
    @IBOutlet weak var carGlyph: UIImageView!

    override var prefersStatusBarHidden: Bool {
        return true
    }


    let routeVC = RouteViewController(nibName: "RouteViewController",
                                         bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        walkingGlyph.image = walkingGlyph.image!.withRenderingMode(.alwaysTemplate)
        walkingGlyph.tintColor = UIColor.blue
        walkingGlyph.backgroundColor = UIColor.black

        bicycleGlyph.image = bicycleGlyph.image!.withRenderingMode(.alwaysTemplate)
        bicycleGlyph.tintColor = UIColor.blue
        bicycleGlyph.backgroundColor = UIColor.black

        carGlyph.image = carGlyph.image!.withRenderingMode(.alwaysTemplate)
        carGlyph.tintColor = UIColor.blue
        carGlyph.backgroundColor = UIColor.black

        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func walkImagePressed(_ sender: Any) {
        print("walk image pressed")
        User.shared.routeType = .run
        self.present(routeVC, animated: true, completion: nil)
    }

    @IBAction func bikeImagePressed(_ sender: Any) {
        print("bike image pressed")
        User.shared.routeType = .bike
        self.present(routeVC, animated: true, completion: nil)
    }

    @IBAction func carImagePressed(_ sender: Any) {
        print("car image pressed")
        User.shared.routeType = .car
        self.present(routeVC, animated: true, completion: nil)
    }

}
