//
//  AppDelegate.swift
//  weather_app_test
//
//  Created by Dilshod Iskandarov on 3/16/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = HomeVC()
        window?.makeKeyAndVisible()
        
        return true
    }

   
}

