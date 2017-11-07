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

public class Listing: NSManagedObject {
    var hint: ListingPostHint {
        get {
            return ListingPostHint(rawValue: self.postHint ?? "")!
        }
    }
}

extension Listing: Managed {
    static func populateObject<T>(fromJSON json: T, save: Bool, moc: NSManagedObjectContext, completionHandler: @escaping ((Error?) -> ())) where T : Decodable {
        
        guard let json = json as? ListingMapped else { fatalError("Failed to cast decodable as ListingData.") }
        
        do {
            let listing: Listing = try Listing.fetchObject(predicate: NSPredicate(format: "id == %@", json.id), moc: moc) ?? Listing.insertObject(context: moc)
            
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
            listing.added = Date()
            
            let results = modifyUrlAndSetIsPlayable(url: json.mediaUrl ?? json.url)
            listing.url = results.url
            listing.isPlayable = results.isPlayable
            
            if let postHint = listing.postHint, let hint = ListingPostHint(rawValue: postHint)  {
                listing.isImage = detectImageUrl(url: listing.url, postHint: hint)
            }
            
            if save {
                try moc.save()
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(error)
        }
    }
    
    static private func detectImageUrl(url: String?, postHint: ListingPostHint) -> Bool {
        guard let url = url else { return false }
        guard let components = URLComponents(string: url) else { return false }
        guard let scheme = components.scheme, scheme == "https" else { return false }
        
        switch postHint {
        case .image, .hostedVideo, .richVideo:
            return true
        case .link:
            if ListingImageFormat.allValues.contains(where:{ components.path.hasSuffix($0.rawValue)  }) {
                return true
            }
        default:
            return false
        }
        return false
    }
    
    static private func modifyUrlAndSetIsPlayable(url: String?) -> (url: String?, isPlayable: Bool) {
        guard let url = url else { return (url: "", isPlayable: false) }
        guard let components = URLComponents(string: url) else { return (url: "", isPlayable: false) }
        var isPlayable: Bool = false
        var modifiedUrlComponents = URLComponents()
        modifiedUrlComponents.scheme = components.scheme
        modifiedUrlComponents.host = components.host
        
        if components.path.hasSuffix("gifv") {
            modifiedUrlComponents.path = components.path.replacingOccurrences(of: "gifv", with: "mp4")
            isPlayable = true
        } else if components.path.hasSuffix("webm") {
            modifiedUrlComponents.path = components.path.replacingOccurrences(of: "webm", with: "mp4")
            isPlayable = true
        } else if components.path.hasSuffix("m3u8") {
            modifiedUrlComponents.path = components.path
            isPlayable = true
        } else {
            modifiedUrlComponents.path = components.path
        }
        
        return (url: modifiedUrlComponents.url?.absoluteString, isPlayable: isPlayable)
    }
}
