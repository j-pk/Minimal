//
//  Listing+CoreDataClass.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData
import Nuke

public class Listing: NSManagedObject {
    var hint: ListingPostHint {
        get {
            return ListingPostHint(rawValue: self.postHint ?? "")!
        }
    }
    
    var type: ListingMediaType {
        get {
            return ListingMediaType(rawValue: self.mediaType)!
        }
    }
    
    var url: URL {
        get {
            return URL(string: urlString)!
        }
    }
    
    //Nuke type for image loading and cache
    var request: ImageRequest {
        get {
            return ImageRequest(url: url)
        }
    }
}

extension Listing: Manageable {
    static func populateObject(fromDecodable json: Decodable, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) {
        guard let json = json as? ListingObject else { fatalError("Failed to cast decodable as ListingObject.") }

        do {
            let listing: Listing = try Listing.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", json.id)) ?? Listing.insertObject(inContext: context)
            
            listing.domain = json.domain
            listing.author = json.author
            listing.created = Date(timeIntervalSince1970: json.created)
            listing.downs = json.downs
            listing.hidden = json.hidden
            listing.id = json.id
            listing.name = json.name
            listing.numberOfComments = json.numberOfComments
            listing.over18 = json.over18
            listing.saved = json.saved
            listing.score = json.score
            listing.subredditId = json.subredditId
            listing.subredditNamePrefixed = json.subredditNamePrefixed
            listing.title = json.title
            listing.before = json.before
            listing.after = json.after
            listing.postHint = json.postHint
            listing.populatedDate = Date()
            listing.permalink = json.permalink
            listing.urlString = modifyUrl(url: json.media?.mediaUrl ?? json.url)
            listing.thumbnailUrlString = json.media?.thumbnailUrl
            let imageSize = determineImageSize(fromDecodable: json)
            listing.width = imageSize.width as NSNumber?
            listing.height = imageSize.height as NSNumber?
            
            
            if let postHint = listing.postHint, let hint = ListingPostHint(rawValue: postHint)  {
                let listingMediaType = determineMediaType(url: listing.urlString, postHint: hint)
                listing.mediaType = listingMediaType.rawValue
            } else {
                listing.mediaType = ListingMediaType.none.rawValue
            }

            if let subredditId = listing.subredditId, let range = subredditId.range(of: "_") {
                let id = subredditId[range.upperBound..<subredditId.endIndex]
                let subreddit: Subreddit? = try Subreddit.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", String(id)))
                listing.subreddit = subreddit
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(error)
        }
    }
    
    /// Determine Image Size
    /// A listing will usually have an array of widths and and heights at various resolutions
    /// This method tries to pick out the ideal size
    ///
    /// - Parameter json: Mapped Listing from JSON
    /// - Returns: Tuple containing Int value for width & height
    static private func determineImageSize(fromDecodable json: ListingObject) -> (width: Int?, height: Int?) {
        var width = json.thumbnailWidth
        var height = json.thumbnailHeight
        let widths = json.images?.first?.resolutions?.map({ $0.width })
        let heights = json.images?.first?.resolutions?.map({ $0.height })
        
        if let widths = widths, let heights = heights {
            if widths.count >= 3 && heights.count >= 3 {
                width = widths[2]
                height = heights[2]
            } else {
                width = widths.endIndex
                height = heights.endIndex
            }
        }
        
        return (width: width, height: height)
    }
    
    /// Determine Media Type using posthint and url
    ///
    /// - Parameters:
    ///   - url: String?
    ///   - postHint: ListingPostHint type
    /// - Returns: ListingMediaType
    static private func determineMediaType(url: String?, postHint: ListingPostHint) -> ListingMediaType {
        guard let url = url else { return .none }
        guard let components = URLComponents(string: url) else { return .none }
        guard let scheme = components.scheme, scheme == "https" else { return .none }
        
        switch postHint {
        case .image:
            if ListingMediaType.animatedImage.format.contains(where:{ components.path.hasSuffix($0.rawValue)  }) {
                return .animatedImage
            }
            return .image
        case .hostedVideo, .richVideo:
            if let host = components.host?.contains("gfycat"), host {
                return .animatedImage
            } else if ListingMediaType.video.format.contains(where:{ components.path.hasSuffix($0.rawValue) }) {
                return .animatedImage
            }
            return .video
        case .link:
            if ListingMediaType.animatedImage.format.contains(where:{ components.path.hasSuffix($0.rawValue)  }) {
                return .animatedImage
            } else if ListingMediaType.image.format.contains(where:{ components.path.hasSuffix($0.rawValue)  }) {
                return .image
            }
        default:
            return .none
        }
        return .none
    }
    
    
    /// Modify url so they work in AVPlayer, AnimatedImageView, or WebView
    ///
    /// - Parameter url: String?
    /// - Returns: String
    static private func modifyUrl(url: String?) -> String {
        guard let url = url else { return "" }
        guard let components = URLComponents(string: url) else { return "" }
        var modifiedUrlComponents = URLComponents()
        modifiedUrlComponents.scheme = components.scheme
        modifiedUrlComponents.host = components.host
        modifiedUrlComponents.queryItems = components.queryItems
        
        if components.path.hasSuffix("gifv") {
            modifiedUrlComponents.path = components.path.replacingOccurrences(of: "gifv", with: "mp4")
        } else if components.path.hasSuffix("webm") {
            modifiedUrlComponents.path = components.path.replacingOccurrences(of: "webm", with: "mp4")
        } else if let host = components.host, host.contains("youtube") || host.contains("youtu.be") {
            if let filteredId = components.queryItems?.filter({ $0.name == "v" }).map({ $0.value }).first, let id = filteredId {
                modifiedUrlComponents.path = components.path.replacingOccurrences(of: "/watch", with: "/embed/\(id)")
                modifiedUrlComponents.queryItems = nil
            } else {
                var pathCopy = components.path
                pathCopy.insert(contentsOf: "/embed", at: pathCopy.startIndex)
                modifiedUrlComponents.host = "youtube.com"
                modifiedUrlComponents.path = pathCopy
            }
        } else if let host = components.host, host.contains("gfycat") && !host.contains("thumbs") {
            var hostCopy = host
            hostCopy.insert(contentsOf: "thumbs.", at: hostCopy.startIndex)
            modifiedUrlComponents.host = hostCopy
            var pathCopy = components.path
            pathCopy.insert(contentsOf: "-size_restricted.gif", at: pathCopy.endIndex)
            modifiedUrlComponents.path = pathCopy
        } else {
            modifiedUrlComponents.path = components.path
        }

        return modifiedUrlComponents.url?.absoluteString ?? ""
    }
}
