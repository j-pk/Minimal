//
//  NSManagedObjectExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/25/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import CoreData

protocol Manageable: class, NSFetchRequestResult {
    static var entityName: String { get }
    static func populateObject(fromDecodable json: Decodable, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler)
}

extension Manageable where Self: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
    
    static func fetchRequestForEntity(inContext context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        return fetchRequest
    }
    
    static func fetchFirst(inContext context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Self? {
        let fetchRequest = fetchRequestForEntity(inContext: context)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 1
        return try context.fetch(fetchRequest).first
    }
    
    static func fetchObjects(inContext context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [Self] {
        let fetchRequest = fetchRequestForEntity(inContext: context)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        return try context.fetch(fetchRequest)
    }
    
    static func insertObject(inContext context: NSManagedObjectContext) throws -> Self {
        do {
            guard let object: Self = try insert(inContext: context) else {
                throw CoreDataError.failedToInsertObject("\(Self.entityName)")
            }
            return object
        } catch let error {
            throw error
        }
    }
    
    private static func insert<T: NSManagedObject>(inContext context: NSManagedObjectContext) throws -> T? where T: Manageable {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: context) as? T else {
            throw CoreDataError.failedToInsertObject("\(T.entityName)")
        }
        return object
    }
    
    static func populateObjects(fromJSON json: [Decodable], database: Database, completionHandler: @escaping OptionalErrorHandler) throws {
        database.performBackgroundTask { (context) in
            do {
                json.forEach { (object) in
                    self.populateObject(fromDecodable: object, context: context, completionHandler: { error in
                        if error != nil {
                            context.rollback()
                            completionHandler(error)
                        }
                    })
                }
                
                if context.hasChanges {
                    try context.save()
                }
                completionHandler(nil)
                
            } catch let error {
                completionHandler(error)
            }
        }
    }
}


