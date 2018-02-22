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

typealias Database = ReadableDatabase & WritableDatabase

protocol WritableDatabase {
    func performForegroundTask(_ context: @escaping (NSManagedObjectContext) -> Void)
    func performBackgroundTask(_ context: @escaping (NSManagedObjectContext) -> Void)
    func purgeAllRecords(_ completionHandler: @escaping OptionalErrorHandler)
    func purgeRecords(entity: String, completionHandler: @escaping OptionalErrorHandler)
    func saveContext(context: NSManagedObjectContext) throws
}

protocol ReadableDatabase {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

protocol Stackable {
    func set(database: DatabaseEngine)
}

class DatabaseEngine {

    // MARK: - Core Data stack
    private let modelName = "Minimal"
    
    //context for UI related tasks
    lazy var viewContext: NSManagedObjectContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return persistentContainer.viewContext
    }()
    
    //background context
    lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = persistentContainer.newBackgroundContext()
        return backgroundContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard error == nil else {
                fatalError("Failed to load store: \(String(describing: error))")
            }
        })
        return container
    }()
}

extension DatabaseEngine: Database {
    func performForegroundTask(_ context: @escaping (NSManagedObjectContext) -> Void) {
        viewContext.perform {
            context(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ context: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(context)
    }
    
    func purgeAllRecords(_ completionHandler: @escaping OptionalErrorHandler) {
        persistentContainer.performBackgroundTask({ context in
            let entitiesByName = self.persistentContainer.managedObjectModel.entities
            
            entitiesByName.forEach({ entityDescription in
                guard let name = entityDescription.name else { return }
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: name))
                
                do {
                    try context.execute(deleteRequest)
                } catch let error {
                    completionHandler(CoreDataError.failedToClearCoreData("\(error)"))
                }
            })
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        })
    }
    
    func purgeRecords(entity: String, completionHandler: @escaping OptionalErrorHandler) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        persistentContainer.performBackgroundTask({ context in
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIdArray = result?.result as? [NSManagedObjectID] else {
                    completionHandler(CoreDataError.failedToPurgeObjects("NSBatchDelete results are nil"))
                    return
                }
                let changes = [NSDeletedObjectsKey : objectIdArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context, self.viewContext])
            } catch let error {
                completionHandler(CoreDataError.failedToPurgeObjects("\(error)"))
            }
            
            DispatchQueue.main.async {
                print("▂▃▅▇█▓▒░ Purged \(entity) ░▒▓█▇▅▃▂")
                completionHandler(nil)
            }
        })
    }
    
    func saveContext(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                throw CoreDataError.failedToSaveContext("\(error)")
            }
        }
    }
}
