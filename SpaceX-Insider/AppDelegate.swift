//
//  AppDelegate.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 22/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return true
    }

}

