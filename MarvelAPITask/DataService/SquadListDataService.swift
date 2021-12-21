//
//  SquadListDataService.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import CoreData
import Foundation

extension SquadListDataService: NSFetchedResultsControllerDelegate {
    
    //MARK: Live updates the squadList array based on whether the controller changes (if an entity is added)
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let entities = controller.fetchedObjects as? [SquadEntity] else { return }
        self.squadList = entities.compactMap({ $0 })
    }
    
}

class SquadListDataService: NSObject {
    @Published var squadList = [SquadEntity]()
    
    var controller: PersistenceController
    
    var viewContext: NSManagedObjectContext {
        return controller.viewContext
    }
    
    let fetchedResultsController: NSFetchedResultsController<SquadEntity>
    
    init(controller: PersistenceController){
        self.controller = controller
        
        let fetchRequest = NSFetchRequest<SquadEntity>(entityName: controller.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        fetchRequest.returnsObjectsAsFaults = false
        self.fetchedResultsController = NSFetchedResultsController<SquadEntity>(fetchRequest: fetchRequest, managedObjectContext: controller.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self
        fetchSquad()
    }
    
    func fetchSquad() {
        do {
            try fetchedResultsController.performFetch()
            guard let entities = fetchedResultsController.fetchedObjects else { return }
            self.squadList = entities.compactMap({ $0 })
        }catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func fireCharacter(entity: SquadEntity){
        viewContext.delete(entity)
        save()
    }
    
    func saveCharacter(character: CharacterViewModel){
        let entity = SquadEntity(context: viewContext)
        entity.characterId = character.id
        entity.name = character.name
        entity.imageURLString = character.imageURLString
        entity.timestamp = Date().timeIntervalSince1970
        save()
    }
    
    func save(){
        do {
            try viewContext.save()
        }catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
}
