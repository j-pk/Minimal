//
//  CommentContract.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let comment = try? newJSONDecoder().decode(Comment.self, from: jsonData)
/*
{
    "kind": "Listing",
    "data": {
        "modhash": "8xoq1cz3zff218bd923a9ad9b834682be6657fe995dcd18a60",
        "dist": null,
            "children": [{
                "kind": "t1",
                "data": {
                    "subreddit_id": "t5_2r7hk",
                    "ups": 1,
                    "link_id": "t3_8ymrvl",
                    "replies": "",
                    "id": "e2cgd2j",
                    "author": "thefundude83",
                    "send_replies": true,
                    "parent_id": "t3_8ymrvl",
                    "score": 1,
                    "downs": 0,
                    "body": "where is the quote?",
                    "edited": false,
                    "collapsed": false,
                    "is_submitter": false,
                    "score_hidden": false,
                    "permalink": "/r/tumblr/comments/8ymrvl/slow_burn_fics/e2cgd2j/",
                    "name": "t1_e2cgd2j",
                    "created_utc": 1531520349,
                    "depth": 0,
                    "author_id": "t2_111749kj"
                }
            }],
        "after": null,
        "before": null
    }
}
*/

// To parse the JSON, add this file to your project and do:
//
//   let commentStore = try? newJSONDecoder().decode(CommentStore.self, from: jsonData)

import Foundation

public typealias CommentStore = [CommentStoreElement]

public struct CommentStoreElement: Codable {
    let kind: String
    let data: CommentStoreData
}

public  struct CommentStoreData: Codable {
    let children: [Child]
    let after, before: JSONNull?
}

public struct Child: Codable {
    let kind: String
    let data: ChildData
}

public struct ChildData: Codable {
    let id, linkID: String
    let name, parentID, author, authorID, body, permalink, subredditID: String?
    let children: [String]?
    let count, score, ups, downs, depth, createdUTC: Int?
    var sendReplies, edited, collapsed, isSubmitter, scoreHidden: Bool?
    let replies: CommentStoreElement?
    
    enum CodingKeys: String, CodingKey {
        case count, name, id
        case parentID = "parent_id"
        case depth, children
        case subredditID = "subreddit_id"
        case ups
        case linkID = "link_id"
        case replies, author
        case sendReplies = "send_replies"
        case score, downs, body, edited, collapsed
        case isSubmitter = "is_submitter"
        case scoreHidden = "score_hidden"
        case permalink
        case createdUTC = "created_utc"
        case authorID = "author_id"
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
        depth = try container.decodeIfPresent(Int.self, forKey: .depth)
        children = try container.decodeIfPresent([String].self, forKey: .children)
        subredditID = try container.decodeIfPresent(String.self, forKey: .subredditID)
        ups = try container.decodeIfPresent(Int.self, forKey: .ups)
        linkID = try container.decodeIfPresent(String.self, forKey: .linkID) ?? ""
        author = try container.decodeIfPresent(String.self, forKey: .author)
        sendReplies = try container.decodeIfPresent(Bool.self, forKey: .sendReplies)
        edited = try? container.decodeIfPresent(Bool.self, forKey: .edited) ?? false
        score = try container.decodeIfPresent(Int.self, forKey: .score)
        downs = try container.decodeIfPresent(Int.self, forKey: .downs)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        collapsed = try container.decodeIfPresent(Bool.self, forKey: .collapsed)
        isSubmitter = try container.decodeIfPresent(Bool.self, forKey: .isSubmitter)
        scoreHidden = try container.decodeIfPresent(Bool.self, forKey: .scoreHidden)
        permalink = try container.decodeIfPresent(String.self, forKey: .permalink)
        createdUTC = try container.decodeIfPresent(Int.self, forKey: .createdUTC)
        authorID = try container.decodeIfPresent(String.self, forKey: .authorID)

        if container.contains(.replies) {
            if let parsedReplies = try? container.decodeIfPresent(CommentStoreElement.self, forKey: .replies) {
                replies = parsedReplies
            } else {
                replies = nil
            }
        } else {
            replies = nil
        }
    }
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
