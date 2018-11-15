//
//  MainModel.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 5/10/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import Gifu

typealias ImageData = (image: UIImage?, data: Data?)

protocol MainListingDelegate {
    func lastViewedSubreddit(data: (subreddit: String, categoryAndTimeFrame: String))
    func presentRecentViewedSubreddits(with controller: UIAlertController)
    func presentCategotyAndTime(with controller: UIAlertController)
    func updateViewWithRequestedListings(for subreddit: String, with categoryAndTimeFrame: String)
}

class MainModel {
    var database: Database?
    var delegate: MainListingDelegate
    init(database: Database, delegate: MainListingDelegate) {
        self.database = database
        self.delegate = delegate
    }
    
    func fetchLastViewedSubredditData() {
        guard let database = database, let user = User.current(context: database.viewContext) else { return }
        let subreddit = user.lastViewedSubreddit != "" ? user.lastViewedSubreddit : "Front Page"
        var categoryAndTimeFrame = user.category.rawValue.capitalized
        if let timeFrame = user.timeFrame?.rawValue.capitalized {
            categoryAndTimeFrame += " | " + timeFrame
        }
        delegate.lastViewedSubreddit(data: (subreddit: subreddit, categoryAndTimeFrame: categoryAndTimeFrame))
    }
    
    private func fetchRecentlyViewedSubreddits() -> [Subreddit] {
        guard let database = database else { return [] }
        let recentPredicate = NSPredicate(format: "isDefault == false && lastViewed < %@ AND lastViewed > %@", Date() as NSDate, Date().subtract(days: 14) as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "lastViewed", ascending: false)
        if let recentSubreddits = try? Subreddit.fetchObjects(inContext: database.viewContext, predicate: recentPredicate, sortDescriptors: [sortDescriptor], fetchLimit: 5) {
            return recentSubreddits
        }
        return []
    }
    
    func buildControllerForRecentlyViewedSubreddits() {
        let themeManager =  ThemeManager()
        let alertController = UIAlertController(title: "Recent Subreddits", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(NSAttributedString(string: "Recent Subreddits", attributes: [NSAttributedString.Key.font: themeManager.font(fontStyle: .primaryBold), NSAttributedString.Key.foregroundColor: themeManager.theme.titleTextColor]), forKey: "attributedTitle")
        
        fetchRecentlyViewedSubreddits().prefix(5).forEach({ subreddit in
            let action = UIAlertAction(title: subreddit.displayName, style: .default, handler: { (action) in
                self.updateUserAndListings(forSubreddit: subreddit, subredditId: subreddit.id, category: .hot, timeFrame: nil)
            })
            alertController.addAction(action)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(cancel)
        delegate.presentRecentViewedSubreddits(with: alertController)
    }
    
    func buildControllerForCategoryAndTimeframe() {
        let themeManager =  ThemeManager()
        let alertController = UIAlertController(title: "Sort by Category", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(NSAttributedString(string: "Sort by Category", attributes: [NSAttributedString.Key.font: themeManager.font(fontStyle: .primaryBold), NSAttributedString.Key.foregroundColor: themeManager.theme.titleTextColor]), forKey: "attributedTitle")
        let timeFrameAlertController = UIAlertController(title: "Time Frame", message: nil, preferredStyle: .actionSheet)
        timeFrameAlertController.setValue(NSAttributedString(string: "Time Frame", attributes: [NSAttributedString.Key.font: themeManager.font(fontStyle: .primaryBold), NSAttributedString.Key.foregroundColor: themeManager.theme.titleTextColor]), forKey: "attributedTitle")
        
        CategorySortType.allCases.forEach({ category in
            let action = UIAlertAction(title: category.rawValue.capitalized, style: .default, handler: { (action) in
                guard let selectedCategory = CategorySortType.allCases.first(where: { $0.rawValue.capitalized == action.title }) else { return }
                if selectedCategory.isSetByTimeframe {
                    CategoryTimeFrame.allCases.forEach({ timeFrame in
                        let action = UIAlertAction(title: timeFrame.titleValue.capitalized, style: .default, handler: { (action) in
                            guard let selectedTimeFrame = CategoryTimeFrame.allCases.first(where: { $0.titleValue.capitalized == action.title }) else { return }
                            self.updateUserAndListings(forSubreddit: nil, subredditId: nil, category: category, timeFrame: selectedTimeFrame)
                        })
                        timeFrameAlertController.addAction(action)
                    })
                    self.delegate.presentCategotyAndTime(with: timeFrameAlertController)
                } else {
                    self.updateUserAndListings(forSubreddit: nil, subredditId: nil, category: selectedCategory, timeFrame: nil)
                }
            })
            alertController.addAction(action)
        })
        delegate.presentCategotyAndTime(with: alertController)
    }
    
    func updateUserAndListings(forSubreddit subreddit: Subreddit? = nil, subredditId: String? = nil, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil) {
        updateUserAndListings(forSubreddit: subreddit, subredditId: subredditId, category: category, timeFrame: timeFrame) { (results) in
            switch results {
            case .failure(let error):
                posLog(error: error)
            case .success(let user):
                self.requestListings() { error in
                    if error != nil {
                        posLog(error: error)
                    }

                    let subreddit = user.lastViewedSubreddit != "" ? user.lastViewedSubreddit : "Home"
                    var category = user.category.rawValue.capitalized
                    if let timeFrame = user.timeFrame?.rawValue.capitalized {
                        category += " | " + timeFrame
                    }
                    self.delegate.updateViewWithRequestedListings(for: subreddit, with: category)
                }
            }
        }
    }
    
    private func updateUserAndListings(forSubreddit subreddit: Subreddit? = nil, subredditId: String? = nil, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil, completionHandler: @escaping ResultCompletionHandler<User>) {
        guard let database = database, let user = User.current(context: database.viewContext) else { return }
        
        if let subreddit = subreddit {
            subreddit.lastViewed = Date()
            user.addToSubreddits(subreddit)
            populateValuesFor(user: user, completionHandler: completionHandler)
        } else if let subredditId = subredditId {
            self.requestSubreddit(withId: subredditId) { (results) in
                switch results {
                case .success(let subreddit):
                    subreddit.lastViewed = Date()
                    user.addToSubreddits(subreddit)
                case .failure(let error):
                    completionHandler(.failure(error))
                    posLog(error: error)
                }
                self.populateValuesFor(user: user, completionHandler: completionHandler)
            }
        } else {
            populateValuesFor(user: user, category: category, timeFrame: timeFrame, completionHandler: completionHandler)
        }
    }
    
    private func populateValuesFor(user: User, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil, completionHandler: @escaping ResultCompletionHandler<User>) {
        guard let database = database else { return }
        if let category = category {
            user.categoryString = category.rawValue
        }
        if let timeFrame = timeFrame {
            user.timeFrameString = timeFrame.rawValue
        } else {
            user.timeFrameString = nil
        }
        database.performForegroundTask { (context) in
            do {
                try context.save()
                completionHandler(.success(user))
            } catch let error {
                completionHandler(.failure(error))
                posLog(error: error)
            }
        }
    }
    
    private func requestSubreddit(withId subredditId: String, completionHandler: @escaping ResultCompletionHandler<Subreddit>) {
        guard let database = database, let id = subredditId.contains("_") ? subredditId.components(separatedBy: "_").last : subredditId else {
            completionHandler(.failure(CoreDataError.failedToFetchObject("Subreddit")))
            return
        }
        
        do {
            if let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: database.viewContext, predicate: NSPredicate(format: "id == %@", id)) {
                completionHandler(.success(subreddit))
            } else {
                let request = SubredditRequest(requestType: .subreddit(id: subredditId))
                SubredditManager(request: request, database: database) { (error) in
                    if let error = error {
                        completionHandler(.failure(error))
                    } else {
                        do {
                            if let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: database.viewContext, predicate: NSPredicate(format: "id == %@", id)) {
                                completionHandler(.success(subreddit))
                            } else {
                                completionHandler(.failure(CoreDataError.failedToFetchObject("Subreddit")))
                            }
                        } catch {
                            completionHandler(.failure(error))
                        }
                    }
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func requestListings(completionHandler: OptionalErrorHandler? = nil) {
        guard let database = self.database, let user = User.current(context: database.viewContext) else { return }
        database.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                posLog(error: error)
                completionHandler?(error)
            } else {
                let request = ListingRequest(requestType: .subreddit(prefix: user.lastViewedSubreddit, category: user.categoryString, timeFrame: user.timeFrameString))
                ListingManager(request: request, database: database, completionHandler: { (error) in
                    if let error = error {
                        posLog(error: error)
                        completionHandler?(error)
                    } else {
                        completionHandler?(nil)
                    }
                })
            }
        })
    }
    
    func paginate(forLastViewedListing listing: Listing) {
        guard let database = database, let user = User.current(context: database.viewContext) else { return }
        let blockOperation = BlockOperation {
            let request = ListingRequest(requestType: .paginate(prefix: user.lastViewedSubreddit, category: user.categoryString, timeFrame: user.timeFrameString, limit: 25, after: listing.after ?? ""))
            ListingManager(request: request, database: database, completionHandler: { (error) in
                if let error = error {
                    posLog(error: error)
                }
            })
        }
        let queue = OperationQueue()
        queue.addOperation(blockOperation)
    }
    
    func fetchAndCacheImage(for listing: Listing, completionHandler: @escaping ((ImageData) -> Void)) {
        switch listing.type {
        case .image:
            if let image = ImageCache.shared[listing.request] {
                completionHandler((image: image, data: nil))
            } else {
                ImagePipeline.shared.loadImage(with: listing.request) { (response, error) in
                    posLog(error: error)
                    ImageCache.shared[listing.request] = response?.image
                    completionHandler((image: response?.image, data: nil))
                }
            }
            
        case .animatedImage:
                if let image = ImageCache.shared[listing.request], let data = image.animatedImageData {
                    completionHandler((image: nil, data: data))
                } else {
                    ImagePipeline.shared.loadImage(with: listing.url) { (response, error) in
                        posLog(error: error)
                        if let image = response?.image, let data = image.animatedImageData {
                            ImageCache.shared[listing.request] = image
                            completionHandler((image: nil, data: data))
                        } else {
                            posLog(message: "No Animated Image Data")
                            completionHandler((image: nil, data: nil))
                        }
                    }
                }
    
        case .video:
            guard let url = URL(string: listing.thumbnailUrlString ?? listing.urlString) else { return }
            let request = ImageRequest(url: url)
            if let image = ImageCache.shared[request] {
                completionHandler((image: image, data: nil))
            } else {
                ImagePipeline.shared.loadImage(with: request) { (response, error) in
                    posLog(error: error)
                    ImageCache.shared[listing.request] = response?.image
                    completionHandler((image: response?.image, data: nil))
                }
            }
            
        default:
            completionHandler((image: nil, data: nil))
        }
    }
    
    func vote(listing: Listing, dir: UserVoteDirection, completionHandler: @escaping OptionalErrorHandler) {
        guard let database = database, let id = listing.id else { return }
        let request = UserRequest(requestType: .vote(id: id, direction: dir))
        UserManager().vote(request: request, direction: dir, database: database, listingManagedObjectId: listing.objectID, completionHandler: completionHandler)
    }
}

