//
//  Listing+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension Listing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Listing> {
        return NSFetchRequest<Listing>(entityName: "Listing")
    }

    @NSManaged public var id: String?
    @NSManaged public var subredditId: String?
    @NSManaged public var name: String?
    @NSManaged public var title: String?
    @NSManaged public var saved: Bool
    @NSManaged public var score: Int32
    @NSManaged public var downs: Int32
    @NSManaged public var over18: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var created: Date?
    @NSManaged public var populatedDate: Date
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var author: String?
    @NSManaged public var subredditNamePrefixed: String?
    @NSManaged public var numberOfComments: Int32
    @NSManaged public var postHint: String?
    @NSManaged public var before: String?
    @NSManaged public var after: String?
    @NSManaged public var domain: String?
    @NSManaged public var mediaType: String
}
