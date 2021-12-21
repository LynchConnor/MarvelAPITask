//
//  CharacterListViewModel.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 21/12/2021.
//

import Combine
import SwiftUI

enum CharacterStatus {
    case loading
    case complete
}

class CharacterListViewModel: ObservableObject {
    
    @Published var characters = [CharacterViewModel]()
    
    @Published var offset: Int = 0
    
    @Published var searchField: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var dataService = CharacterListDataService()
    
    let squadListVM: SquadListViewModel
    
    init(_ squadListVM: SquadListViewModel){
        self.squadListVM = squadListVM
        searchCharacters()
    }
    
    func fetchCharacters(){
        Task {
            await dataService.fetchCharacters(offset: offset)
            dataService.$characters.sink { charactersList in
                DispatchQueue.main.async {
                    self.characters = charactersList
                }
            }
            .store(in: &cancellables)
        }
    }
    
    private func searchCharacters(){
        $searchField
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { value in
                if !(value.isEmpty){
                    Task {
                        await self.dataService.searchCharacters(query: self.searchField)
                        self.dataService.$characters.sink { charactersList in
                            DispatchQueue.main.async {
                                self.characters = charactersList
                            }
                        }
                        .store(in: &self.cancellables)
                    }
                }else{
                    self.dataService.characters = []
                    self.fetchCharacters()
                }
            }
            .store(in: &cancellables)
    }
    
    func checkLastCharacter(id: CharacterViewModel.ID){
        
        let maxCount = characters.count - 5
        
        if !(characters.isEmpty) && characters[maxCount].id == id {
            self.offset += characters.count
            fetchCharacters()
        }
    }
}
