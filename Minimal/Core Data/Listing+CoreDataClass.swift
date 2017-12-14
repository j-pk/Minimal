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
            return URL(string: thumbnailUrlString ?? urlString)!
        }
    }
    
    //Nuke type for image loading and cache
    var request: Request {
        get {
            return Request(url: url)
        }
    }
}

extension Listing: Manageable {
    static func populateObject<T>(fromJSON json: T, save: Bool, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) where T : Decodable {
        
        guard let json = json as? ListingMapped else { fatalError("Failed to cast decodable as ListingObject.") }

        do {
            let listing: Listing = try Listing.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", json.id)) ?? Listing.insertObject(inContext: context)
            
            listing.domain = json.domain
            listing.author = json.author
            listing.created = json.created
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
            listing.urlString = modifyUrl(url: json.mediaUrl ?? json.url)
            listing.thumbnailUrlString = json.thumbnailUrl
            let imageSize = determineImageSize(fromJSON: json)
            listing.width = imageSize.width as NSNumber?
            listing.height = imageSize.height as NSNumber?
            
            
            if let postHint = listing.postHint, let hint = ListingPostHint(rawValue: postHint)  {
                let listingMediaType = determineMediaType(url: listing.urlString, postHint: hint)
                listing.mediaType = listingMediaType.rawValue
            } else {
                listing.mediaType = ListingMediaType.none.rawValue
            }

            if save {
                try context.save()
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
    static private func determineImageSize(fromJSON json: ListingMapped) -> (width: Int?, height: Int?) {
        var width = json.thumbnailWidth
        var height = json.thumbnailHeight
        if let widths = json.widths, let heights = json.heights {
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
            if let id = components.queryItems?.filter({ $0.name == "v" }).flatMap({ $0.value }).first {
                modifiedUrlComponents.path = components.path.replacingOccurrences(of: "/watch", with: "/embed/\(id)")
                modifiedUrlComponents.queryItems = nil
            } else {
                var pathCopy = components.path
                pathCopy.insert(contentsOf: "/embed", at: pathCopy.startIndex)
                modifiedUrlComponents.host = "youtube.com"
                modifiedUrlComponents.path = pathCopy
            }
        } else if let host = components.host, host.contains("gfycat") {
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
