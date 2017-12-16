//
//  User+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/5/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var labelNsfw: Bool
    @NSManaged public var lastAuthenticated: NSDate?
    @NSManaged public var lastViewedSubreddit: String?
    @NSManaged public var over18: Bool
    @NSManaged public var searchIncludeOver18: Bool
    @NSManaged public var timeframeString: String?
    @NSManaged public var categoryString: String
}
