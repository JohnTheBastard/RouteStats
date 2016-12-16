//
//  Extensions.swift
//  RouteStats
//
//  Created by John D Hearn on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.

import UIKit
import CoreLocation

extension UIResponder{
    static var identifier: String{
        return String(describing: self)
    }
}

extension URL{
    static func dataURL() -> URL{

        guard let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("Error getting document directories.") }

        return documentsDirectory.appendingPathComponent("routeData")
    }
}
