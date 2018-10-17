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

import Foundation

struct CommentStore: Codable {
    let kind: String
    let data: CommentData
}

struct CommentData: Codable {
    let modhash: String
    let dist: JSONNull?
    let children: [Child]
    let after, before: JSONNull?
}

struct Child: Codable {
    let kind: String
    let data: ChildData
}

struct ChildData: Codable {
    let subredditID: String
    let ups: Int
    let replies: CommentStore
    let linkID, id, author: String
    let sendReplies: Bool
    let parentID: String
    let score, downs: Int
    let body: String
    let edited, collapsed, isSubmitter, scoreHidden: Bool
    let permalink, name: String
    let createdUTC, depth: Int
    let authorID: String
    
    enum CodingKeys: String, CodingKey {
        case subredditID = "subreddit_id"
        case ups
        case linkID = "link_id"
        case replies, id, author
        case sendReplies = "send_replies"
        case parentID = "parent_id"
        case score, downs, body, edited, collapsed
        case isSubmitter = "is_submitter"
        case scoreHidden = "score_hidden"
        case permalink, name
        case createdUTC = "created_utc"
        case depth
        case authorID = "author_id"
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
