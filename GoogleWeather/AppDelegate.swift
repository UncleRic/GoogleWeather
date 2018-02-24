//
//  AppDelegate.swift
//  GoogleWeather
//
//  Created by Frederick C. Lee on 2/6/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func applicationDidFinishLaunching(_ application: UIApplication) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let mainVC = MainViewController()
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
    }
}

