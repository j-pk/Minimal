//
//  ListingEnums.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

enum ListingCategoryType {
    case hot
    case new
    case rising
    case controversial
    case top
    
    var stringValue: String {
        switch self {
        case .hot: return ""
        case .new: return "new"
        case .rising: return "rising"
        case .controversial: return "controversial"
        case .top: return "top"
        }
    }
    
    var titleValue: String {
        switch self {
        case .hot: return "hot"
        case .new: return "new"
        case .rising: return "rising"
        case .controversial: return "controversial"
        case .top: return "top"
        }
    }
    
    var isSetByTimeFrame: Bool {
        switch self {
        case .controversial, .top: return true
        default:
            return false
        }
    }
    
    static let allValues = [hot, new, rising, controversial, top]
}

enum CategoryTimeFrame {
    case hour
    case twentyFourHours
    case week
    case month
    case year
    case allTime
    
    static let allValues = [hour, twentyFourHours, week, month, year, allTime]
}

enum ListingPostHint: String {
    case link
    case image
    case none = ""
    case subreddit = "self"
    case richVideo = "rich:video" //YouTube
    case hostedVideo = "hosted:video" 
}

enum ListingImageFormat: String {
    case png
    case jpeg
    case jpg
    case gif
    case mp4
    case gifv
    case webm
    static let allValues = [png, jpeg, jpg, gif, mp4, gifv, webm]
}
