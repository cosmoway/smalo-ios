//
//  AppDelegate.swift
//  smalo-ios
//
//  Created by Tetsu Susaki on 2016/04/07.
//  Copyright (c) 2016 COSMOWAY inc. All rights reserved.
//

import UIKit
import Pulsator


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pulsator: Pulsator?
    var doorState: String?
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        
        // ログイン判定
        let ud = UserDefaults.standard
        let isLogin = ud.object(forKey: "isLogin") as? Bool
        let storyboard = UIStoryboard(name: "Main",bundle:nil)
        
        // 未ログインの場合
        if isLogin != nil && isLogin! {
            let viewController = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
            navigationController = UINavigationController(rootViewController: viewController)
            navigationController?.isNavigationBarHidden = true
            self.window?.rootViewController = navigationController
            // ログイン中の場合
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier: "login") as UIViewController
            navigationController = UINavigationController(rootViewController: viewController)
            navigationController?.isNavigationBarHidden = true
            self.window?.rootViewController = navigationController
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        pulsator?.stop()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if doorState == "" || doorState == nil {
            pulsator?.start()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

