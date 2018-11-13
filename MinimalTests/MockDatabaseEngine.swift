//
//  MockDatabaseEngine.swift
//  MinimalTests
//
//  Created by Jameson Kirby on 11/12/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import XCTest
import Foundation
import CoreData
@testable import Minimal

class MockDatabaseEngine: DatabaseEngine {
    
    override var persistentContainer: NSPersistentContainer {
        get {
            return _persistentContainer
        }
        set {
            _persistentContainer = newValue
        }
    }
    
    private var _persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.main.url(forResource: "Minimal", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: "Minimal", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
    
    lazy var mockViewContext: NSManagedObjectContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return persistentContainer.viewContext
    }()
    
    func setup() {
        User.create(context: mockViewContext) { (error) in
            
        }
    }
}
