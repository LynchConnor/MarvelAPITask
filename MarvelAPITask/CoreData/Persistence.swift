//
//  Persistence.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let containerName: String = "MarvelAPITask"
    let entityName: String = "SquadEntity"

    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    init() {
        container = NSPersistentContainer(name: containerName)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
            }
        })
    }
}
