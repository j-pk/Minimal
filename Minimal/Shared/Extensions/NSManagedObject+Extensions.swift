//
//  NSManagedObject+Extensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/25/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import CoreData

protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static func populateObject<T: Decodable>(fromJSON json: T, save: Bool, moc: NSManagedObjectContext, completionHandler: @escaping ((Error?)->()))
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
    
    static func fetchObject(predicate: NSPredicate, moc: NSManagedObjectContext) throws -> Self? {
        do {
            guard let object = try CoreDataManager.default.fetch(Self.entityName, predicate: predicate, fetchLimit: 1, moc: moc) as? [Self] else { return nil }
            return object.first
        } catch let error {
            throw CoreDataError.failedToFetchObject("\(error)")
        }
    }
    
    static func insertObject(context: NSManagedObjectContext) throws -> Self {
        do {
            guard let object: Self = try insert(context: context) else {
                throw CoreDataError.failedToInsertObject("\(Self.entityName)")
            }
            return object
        } catch let error {
            throw error
        }
    }
    
    private static func insert<T: NSManagedObject>(context: NSManagedObjectContext) throws -> T? where T: Managed {
        
        guard let object = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: context) as? T else {
            throw CoreDataError.failedToInsertObject("\(T.entityName)")
        }
        return object
    }
    
    static func populateObjects<T: Mappable>(fromJSON json: [T], completionHandler: @escaping ((Error?)->())) throws {
        CoreDataManager.default.performBackgroundTask { (moc) in
            do {
                json.forEach { (object) in
                    self.populateObject(fromJSON: object, save: false, moc: moc, completionHandler: { error in
                        if error != nil {
                            completionHandler(error)
                        }
                    })
                }
                
                if moc.hasChanges {
                    try moc.save()
                }
                completionHandler(nil)
                
            } catch let error {
                completionHandler(error)
            }
        }
    }
}


