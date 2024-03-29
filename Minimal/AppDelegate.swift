//
//  AppDelegate.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

// Note: For reference, the execution order of the relevant methods is as follows:
//
// AppDelegate.init()
// ViewController.init()
// AppDelegate.application(_:willFinishLaunchingWithOptions:)
// AppDelegate.application(_:didFinishLaunchingWithOptions:)
// ViewController.viewDidLoad()

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let database = DatabaseEngine()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        posLog(values:paths[0]) 
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        configureDatabase()
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
            try database.viewContext.save()
        } catch let error {
            posLog(error: error)
        }
    }
}

/// Override point for customization after application launch.
extension AppDelegate {
    
    func configureDatabase() {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            tabBarController.viewControllers?.forEach({ (controller) in
                if let navigationController = controller as? HiddenNavBarNavigationController {
                    let controller = navigationController.viewControllers.first as? Stackable
                    controller?.set(database: database)
                } else if let controller = controller as? Stackable {
                    controller.set(database: database)
                }
            })
        }
    }
    
    func configureTheme() {
        ThemeManager().setGlobalTheme()
        ThemeManager().setGlobalFont()
    }
    
    private func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserSettingsDefaultKey.firstLaunch)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: UserSettingsDefaultKey.firstLaunch)
            Defaults()
        }
        return isFirstLaunch
    }
    
    // Create user on first launch or check for one, should only ever have 1 user
    func configureUser() {
        database.performBackgroundTask({ [weak self] (context) in
            guard let this = self else { return }
            if this.isFirstLaunch() {
                User.create(context: context, completionHandler: { (error) in
                    posLog(error: error)
                })
                Subreddit.populateDefaultSubreddits(database: this.database)
                SearchSubredditManager(database: this.database)
                this.requestListings(database: this.database)
            } else {
                do {
                    guard try User.fetchFirst(inContext: context) != nil else { return } //TODO: Hmm
                } catch let error {
                    posLog(error: error)
                }
            }
        })
    }
    
    // Kick off listing request to have collectionView populated on load
    func requestListings(database: Database) {
        database.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                posLog(error: error)
            } else {
                let request = ListingRequest(requestType: .subreddit(prefix: "", category: nil, timeFrame: nil))
                ListingManager(request: request, database: database, completionHandler: { (error) in
                    if let error = error {
                        posLog(error: error)
                    }
                })
            }
        })
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        if keyWindow?.rootViewController == nil {
            return keyWindow?.rootViewController
        }
        
        var pointedViewController = keyWindow?.rootViewController
        
        while  pointedViewController?.presentedViewController != nil {
            switch pointedViewController?.presentedViewController {
            case let navagationController as UINavigationController:
                pointedViewController = navagationController.viewControllers.last
            case let tabBarController as UITabBarController:
                pointedViewController = tabBarController.selectedViewController
            default:
                pointedViewController = pointedViewController?.presentedViewController
            }
        }
        return pointedViewController
    }
}

