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


    let promptedVC = RouteViewController(nibName: "RouteViewController",
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
        self.present(promptedVC, animated: true, completion: nil)
    }

    @IBAction func bikeImagePressed(_ sender: Any) {
        print("bike image pressed")
        self.present(promptedVC, animated: true, completion: nil)
    }

    @IBAction func carImagePressed(_ sender: Any) {
        print("car image pressed")
        self.present(promptedVC, animated: true, completion: nil)
    }

}
