//
//  AppDelegate.swift
//  learning
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow()
        let viewController = ViewController(nibName: "ViewController", bundle: nil);
        window.rootViewController = viewController;
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

