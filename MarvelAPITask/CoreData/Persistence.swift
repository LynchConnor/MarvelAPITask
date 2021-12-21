//
//  Persistence.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import CoreData

enum StorageType {
    case persistent, inMemory
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    let containerName: String = "MarvelAPITask"
    let entityName: String = "SquadEntity"
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(_ storageType: StorageType = .persistent) {
        
        container = NSPersistentContainer(name: containerName)
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
            }
        })
    }
}
