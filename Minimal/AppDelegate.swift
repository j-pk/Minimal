//
//  AppDelegate.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        
        configureTheme()
        configureUser()
        
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
        do {
            try CoreDataManager.default.viewContext.save()
        } catch let error {
            print(error)
        }
    }
}

// Override point for customization after application launch.
private extension AppDelegate {
    
    func configureTheme() {
        ThemeManager().setGlobalTheme()
        ThemeManager().setGlobalFont()
    }
    
    private func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserSettingsDefaultKey.firstLaunch)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: UserSettingsDefaultKey.firstLaunch)
        }
        return isFirstLaunch
    }
    
    
    /// Create user on first launch or check for one, should only ever have 1 user
    func configureUser() {
        CoreDataManager.default.performBackgroundTask({ [weak self] (moc) in
            guard let this = self else { return }
            if this.isFirstLaunch() {
                User.create(context: moc, completionHandler: { (error) in
                    print(error as Any)
                })
                Subreddit.insertDefaultSubreddits()
                SearchSubredditManager()
                this.requestListings()
            } else {
                do {
                    guard try User.fetchFirst(inContext: moc) != nil else { return } //TODO: Hmm
                } catch let error {
                    print(error as Any)
                }
            }
        })
    }
    
    /// Kick off listing request to have collectionView populated on load
    func requestListings() {
        CoreDataManager.default.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                print(error)
            } else {
                let request = ListingRequest(subreddit: "", category: nil)
                ListingManager(request: request, completionHandler: { (error) in
                    if let error = error {
                        print(error)
                    }
                })
            }
        })
    }
}

