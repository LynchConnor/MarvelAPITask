//
//  SquadListViewModel.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 21/12/2021.
//

import Combine
import Foundation

class SquadListViewModel: ObservableObject {
    @Published var squadEntities = [SquadEntity]()
    
    let squadMaxCount: Int = 5
    
    let squadListDataService: SquadListDataService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ controller: PersistenceController){
        self.squadListDataService = SquadListDataService(controller: controller)
        fetchSquad()
    }
    
    var remaining: Int {
        return 5-squadEntities.count
    }
    
    var remainingIsGreaterThanZero: Bool {
        return remaining > 0
    }
    
    var squadHeaderIsVisible: Bool {
        return squadCount < squadMaxCount
    }
    
    var squadCount: Int {
        return squadEntities.count
    }
    
    var squadRemaining: Int {
        return squadMaxCount - squadEntities.count
    }
    
    func fireCharacter(id: String){
        guard let entity = squadEntities.first(where: { $0.characterId == id }) else { return }
        squadListDataService.fireCharacter(entity: entity)
    }
    
    func recruitCharacter(character: CharacterViewModel, completion: @escaping () -> ()){
        
        if !(squadEntities.contains(where: { $0.characterId == character.id })) && (squadEntities.count < 5){
            squadListDataService.saveCharacter(character: character)
            completion()
        }
    }
    
    func fetchSquad(){
        squadListDataService.$squadList.sink { squadEntities in
            self.squadEntities = squadEntities
        }
        .store(in: &cancellables)
    }
}
