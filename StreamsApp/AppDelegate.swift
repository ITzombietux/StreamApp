//
//  AppDelegate.swift
//  StreamsApp
//
//  Created by zombietux on 17/01/2019.
//  Copyright © 2019 zombietux. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "..."
            $0.clientKey = "..."
            $0.server = "..."
        }
        
        Parse.initialize(with: configuration)
        
        PFUser.logOut()
        
        var streamVC:StreamViewController = StreamViewController()
        streamVC.title = "Streams"
        
        var navigationVC:UINavigationController = UINavigationController(rootViewController: streamVC)
        
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        window!.rootViewController = navigationVC
        window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}

