//
//  CoreDataManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/25/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import CoreData

enum CoreDataError: Error {
    case failedToInsertObject(String)
    case failedToFetchObject(String)
    case failedToPurgeObjects(String)
    case failedToSaveContext(String)
    case failedToClearCoreData(String)
}

class CoreDataManager {
    
    // MARK: - Core Data stack
    static let `default` = CoreDataManager()
    private let momdName = "Minimal"
    
    //context for UI related tasks
    public lazy var viewContext: NSManagedObjectContext = {
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return self.persistentContainer.viewContext
    }()
    
    //background context
    public lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = self.persistentContainer.newBackgroundContext()
        return backgroundContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: self.momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: self.momdName, managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard error == nil else {
                fatalError("Failed to load store: \(String(describing: error))")
            }
        })
        return container
    }()
    
    func performForegroundTask(_ context: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            context(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ context: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(context)
    }
    
    func fetch(_ entity: String, predicate: NSPredicate? = nil, fetchLimit: Int = 0, sort: [NSSortDescriptor]? = nil, moc: NSManagedObjectContext) throws -> [AnyObject]? {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetch.predicate = predicate
        fetch.sortDescriptors = sort
        fetch.fetchLimit = fetchLimit
        do {
            let result = try moc.fetch(fetch)
            return result
        } catch let error {
            throw CoreDataError.failedToFetchObject("\(entity): \(error)")
        }
    }
    
    // MARK: - Core Data Purge support
    func clearCoreData(_ completionHandler: @escaping ((Error?) -> ())) {
        self.persistentContainer.performBackgroundTask({ moc in
            let entitiesByName = self.persistentContainer.managedObjectModel.entities
            
            entitiesByName.forEach({ entityDescription in
                guard let name = entityDescription.name else { return }
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: name))
                
                do {
                    try moc.execute(deleteRequest)
                } catch let error {
                    completionHandler(CoreDataError.failedToClearCoreData("\(error)"))
                }
            })
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        })
    }
    
    func purgeRecords(_ predicate: NSPredicate, entity: String, completionHandler: @escaping ((Error?) -> ())) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        self.persistentContainer.performBackgroundTask({ moc in
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try moc.execute(deleteRequest)
            } catch let error {
                completionHandler(CoreDataError.failedToPurgeObjects("\(error)"))
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        })
    }
    
    // MARK: - Core Data Saving support
    func saveContext (context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                throw CoreDataError.failedToSaveContext("\(error)")
            }
        }
    }
}
