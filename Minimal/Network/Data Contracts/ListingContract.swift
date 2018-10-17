//
//  ListingContract.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

// Example JSON https://www.reddit.com/hot/.json

struct ListingStore: Decodable {
    let before: String?
    let after: String?
    let listings: [ListingObject]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum ChildrenCodingKeys: String, CodingKey {
        case listings = "children"
        case before
        case after
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let data = try root.nestedContainer(keyedBy: ChildrenCodingKeys.self, forKey: .data)
        before = try data.decodeIfPresent(String.self, forKey: .before)
        after = try data.decodeIfPresent(String.self, forKey: .after)
        listings = try data.decode([ListingObject].self, forKey: .listings)
    }
}

struct ListingObject: Decodable {
    let kind: String
    let id: String
    var before: String? = nil
    var after: String? = nil
    let subredditId: String
    let name: String
    let title: String
    let saved: Bool
    let score: Int32
    let downs: Int32
    let postHint: String?
    let over18: Bool
    let hidden: Bool
    let created: Double
    let permalink: String
    let url: String
    let author: String
    let subredditNamePrefixed: String
    let numberOfComments: Int32
    let domain: String
    let thumbnailWidth: Int?
    let thumbnailHeight: Int?
    let images: [Image]?
    let media: Media?
    
    enum KindCodingKeys: String, CodingKey {
        case kind
        case listing = "data"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case id
        case subredditId = "subreddit_id"
        case name
        case title
        case saved
        case score
        case downs
        case postHint = "post_hint"
        case over18 = "over_18"
        case hidden
        case created = "created_utc"
        case permalink
        case url
        case author
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case numberOfComments = "num_comments"
        case domain
        case media
        case oembed
        case redditVideo = "reddit_video"
        case preview
        case images
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
    
    enum CodingError: Error {
        case unrecognizedVersion(String, Swift.DecodingError.Context)
        case contentMissing(Swift.DecodingError.Context)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: KindCodingKeys.self)
        kind = try values.decode(String.self, forKey: .kind)
        
        let data = try values.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .listing)
        id = try data.decode(String.self, forKey: .id)
        subredditId  = try data.decode(String.self, forKey: .subredditId)
        name = try data.decode(String.self, forKey: .name)
        title = try data.decode(String.self, forKey: .title)
        saved = try data.decode(Bool.self, forKey: .saved)
        score = try data.decode(Int32.self, forKey: .score)
        downs = try data.decode(Int32.self, forKey: .downs)
        postHint = try data.decodeIfPresent(String.self, forKey: .postHint)
        over18 = try data.decode(Bool.self, forKey: .over18)
        hidden = try data.decode(Bool.self, forKey: .hidden)
        created = try data.decode(Double.self, forKey: .created)
        url = try data.decode(String.self, forKey: .url)
        permalink = try data.decode(String.self, forKey: .permalink)
        author = try data.decode(String.self, forKey: .author)
        subredditNamePrefixed = try data.decode(String.self, forKey: .subredditNamePrefixed)
        numberOfComments = try data.decode(Int32.self, forKey: .numberOfComments)
        domain = try data.decode(String.self, forKey: .domain)
        thumbnailWidth = try data.decodeIfPresent(Int.self, forKey: .thumbnailWidth)
        thumbnailHeight = try data.decodeIfPresent(Int.self, forKey: .thumbnailHeight)
        
        if data.contains(.preview) {
            let preview = try data.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .preview)
            images = try preview.decodeIfPresent([Image].self, forKey: .images)
        } else {
            images = nil
        }
        
        if try data.decodeNil(forKey: .media) == false  {
            let embedded = try data.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .media)
            if embedded.contains(.oembed) {
                media = try embedded.decodeIfPresent(Media.self, forKey: .oembed)
            } else if embedded.contains(.redditVideo) {
                media = try embedded.decodeIfPresent(Media.self, forKey: .redditVideo)
            } else {
                media = nil
            }
        } else {
            media = nil
        }
    }
    
    struct Image: Decodable {
        let resolutions: [Resolution]?
        
        enum ImagesCodingKeys: String, CodingKey {
            case resolutions
        }
        
        init(from decoder: Decoder) throws {
            let data = try decoder.container(keyedBy: ImagesCodingKeys.self)
            resolutions = try data.decodeIfPresent([Resolution].self, forKey: .resolutions)
        }
        
        struct Resolution: Decodable {
            let width: Int?
            let height: Int?
            
            enum ResolutionsCodingKeys: String, CodingKey {
                case width
                case height
            }
            
            init(from decoder: Decoder) throws {
                let resolutions = try decoder.container(keyedBy: ResolutionsCodingKeys.self)
                width = try resolutions.decodeIfPresent(Int.self, forKey: .width)
                height = try resolutions.decodeIfPresent(Int.self, forKey: .height)
            }
        }
    }
    
    struct Media: Decodable {
        let mediaUrl: String?
        let thumbnailUrl: String?
        
        enum MediaCodingKeys: String, CodingKey {
            case mediaUrl = "author_url"
            case hlsUrl = "hls_url"
            case thumbnailUrl = "thumbnail_url"
        }
        
        init(from decoder: Decoder) throws {
            let media = try decoder.container(keyedBy: MediaCodingKeys.self)
            thumbnailUrl = try media.decodeIfPresent(String.self, forKey: .thumbnailUrl)
            mediaUrl = try media.decodeIfPresent(String.self, forKey: .hlsUrl)
        }
    }
}
