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

class MainModel {
    private var database: Database?
    
    init(database: Database) {
        self.database = database
    }
    
    func fetchLastViewedSubredditData() -> (subreddit: String, categoryAndTimeFrame: String) {
        guard let database = database, let user = User.current(context: database.viewContext) else { return (subreddit: "", categoryAndTimeFrame: "") }
        let subreddit = user.lastViewedSubreddit != "" ? user.lastViewedSubreddit : "Front Page"
        var categoryAndTimeFrame = user.category.rawValue.capitalized
        if let timeFrame = user.timeFrame?.rawValue.capitalized {
            categoryAndTimeFrame += " | " + timeFrame
        }
        return (subreddit: subreddit, categoryAndTimeFrame: categoryAndTimeFrame)
    }
    
    func updateUserAndListings(forSubreddit subreddit: Subreddit? = nil, subredditId: String? = nil, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil, completionHandler: ((String, String) -> Void)? = nil) {
        
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
                    completionHandler?(subreddit, category)
                }
            }
        }
    }
    
    private func updateUserAndListings(forSubreddit subreddit: Subreddit? = nil, subredditId: String? = nil, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil, completionHandler: @escaping ResultCompletionHandler<User>) {
        guard let database = database, let user = User.current(context: database.viewContext) else { return }
        database.performForegroundTask { (context) in
            if let subredditId = subredditId, subreddit == nil {
                self.requestSubreddit(withId: subredditId) { (results) in
                    switch results {
                    case .success(let subreddit):
                        subreddit.lastViewed = Date()
                        user.addToSubreddits(subreddit)
                    case .failure(let error):
                        completionHandler(.failure(error))
                        posLog(error: error)
                    }
                }
            } else {
                if let subreddit = subreddit {
                    subreddit.lastViewed = Date()
                    user.addToSubreddits(subreddit)
                }
                if let category = category {
                    user.categoryString = category.rawValue
                }
                if let timeFrame = timeFrame {
                    user.timeFrameString = timeFrame.rawValue
                } else {
                    user.timeFrameString = nil
                }
            }
            
            do {
                try context.save()
                completionHandler(.success(user))
            } catch let error {
                completionHandler(.failure(error))
                posLog(error: error)
            }
        }
    }


    func requestSubreddit(withId subredditId: String, completionHandler: @escaping ResultCompletionHandler<Subreddit>) {
        guard let database = database else { return }
        do {
            if let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: database.viewContext, predicate: NSPredicate(format: "id CONTAINS[c] %@", subredditId)) {
                completionHandler(.success(subreddit))
            } else {
                let request = SubredditRequest(requestType: .subreddit(id: subredditId))
                SubredditManager(request: request, database: database) { (error) in
                    if let error = error {
                        completionHandler(.failure(error))
                    } else {
                        do {
                            if let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: database.viewContext, predicate: NSPredicate(format: "id MATCHES %@", subredditId.split(separator: "_")[1] as CVarArg)) {
                                completionHandler(.success(subreddit))
                            }
                            completionHandler(.failure(CoreDataError.failedToFetchObject("Subreddit")))
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
}
