//
//  CharacterListView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SDWebImageSwiftUI
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
            print("DEBUG: Fetching")
            await dataService.fetchCharacters(offset: offset)
            dataService.$characters.sink { charactersList in
                DispatchQueue.main.async {
                    print("DEBUG: Characters set")
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
                            print("DEBUG: Searching")
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

struct CharacterListView: View {
    
    @StateObject var viewModel: CharacterListViewModel
    
    init(viewModel: CharacterListViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10, alignment: .center),
        GridItem(.flexible(), spacing: 10, alignment: .center)
    ]
    
    var body: some View {
        VStack {
            
            TextField("Enter...", text: $viewModel.searchField)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
                .padding(.horizontal, 10)
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(viewModel.characters) { character in
                    NavigationLink {
                        LazyView(CharacterDetailView(viewModel: CharacterDetailView.ViewModel(state: .user(character: character), viewModel.squadListVM)))
                    } label: {
                        CharacterListCellView(CharacterListCellView.ViewModel(character, viewModel.squadListVM))
                            .onAppear(perform: {
                                viewModel.checkLastCharacter(id: character.id)
                            })
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct CharacterListView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListView(viewModel: CharacterListViewModel(SquadListViewModel(PersistenceController.shared)))
    }
}
