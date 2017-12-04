//
//  AppDelegate.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

//redirect uri minimalApp://minimalApp.com
//client id t6Z4BZyV3a06eA

//authorization url
//https://www.reddit.com/api/v1//api/v1/authorize.compact?client_id=CLIENT_ID&response_type=code&state=RANDOM_STRING&redirect_uri=minimalApp://minimalApp.com&duration=permanent&scope=identity,vote,read,subscribe,mysubreddits

//state user defaults random string to compare on uri redirect

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        
        //configureTheme()
        
        CoreDataManager.default.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                print(error)
            } else {
                SyncManager.default.syncListings(prefix: "", category: nil, timeframe: nil) { (error) in
                    if let error = error {
                        print(error)
                    }
                }
            }
        })
        return true
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
        // Saves changes in the application's managed object context before the application terminates.
//        do {
//            try CoreDataManager.default.saveContext()
//        } catch {
//            print(error)
//        }
    }
}

// Override point for customization after application launch.

extension AppDelegate {
    
    func configureTheme() {
        ThemeManager.setGlobalTheme()
    }
}

