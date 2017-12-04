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
    
    var titleValue: String {
        switch self {
        case .hour: return "1 hour"
        case .twentyFourHours: return "24 hours"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        case .allTime: return "all time"
        }
    }
    
    static let allValues = [hour, twentyFourHours, week, month, year, allTime]
}

enum ListingPostHint: String {
    case link
    case image
    case none = ""
    case subreddit = "self"
    case richVideo = "rich:video" //YouTube gfycat 
    case hostedVideo = "hosted:video" 
}

enum ListingMediaType: String {
    case image
    case animatedImage
    case video
    case none
    
    var format: [ListingMediaFormat] {
        switch self {
        case .image:
            return [.png, .jpg, .jpeg]
        case .animatedImage:
            return [.gif, .mp4]
        case .video:
            return [.m3u8]
        case .none:
            return []
        }
    }
}

enum ListingMediaFormat: String {
    case png
    case jpeg
    case jpg
    case gif
    case mp4
    case m3u8
    static let allValues = [png, jpeg, jpg, gif, mp4, m3u8]
}
