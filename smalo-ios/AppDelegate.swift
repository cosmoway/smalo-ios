//
//  AppDelegate.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import Pulsator


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pulsator: Pulsator?
    var doorState: String?
    var navigationController: UINavigationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        // ログイン判定
        let ud = NSUserDefaults.standardUserDefaults()
        let isLogin: Bool? = ud.objectForKey("isLogin") as? Bool
        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        
        // 未ログインの場合
        if isLogin != nil && isLogin! {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController
            navigationController = UINavigationController(rootViewController: viewController)
            navigationController?.navigationBarHidden = true
            self.window?.rootViewController = navigationController
            // ログイン中の場合
        } else {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController
            navigationController = UINavigationController(rootViewController: viewController)
            navigationController?.navigationBarHidden = true
            self.window?.rootViewController = navigationController
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        pulsator?.stop()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if doorState == "" || doorState == nil {
            pulsator?.start()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

