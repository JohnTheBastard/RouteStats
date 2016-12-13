 //
//  AppDelegate.swift
//  SpeedTracker
//
//  Created by John D Hearn and Jake Dobson on 11/7/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow()

        self.window?.rootViewController = getTabBar()
        self.window?.makeKeyAndVisible()

        return true
    }

    func getTabBar() -> UITabBarController {

        let tabBarController = UITabBarController()

        let selectionVC = SelectionViewController(nibName: "SelectionViewController", bundle: nil)
        let statsVC = StatsViewController(nibName: "StatsViewController", bundle: nil)

        tabBarController.viewControllers = [selectionVC, statsVC]

        selectionVC.tabBarItem = UITabBarItem(title: "Route", image: UIImage(named: "map-glyph"), tag: 0)
        statsVC.tabBarItem = UITabBarItem(title: "Stats", image: UIImage(named: "stats-glyph"), tag: 1)

        return tabBarController

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

