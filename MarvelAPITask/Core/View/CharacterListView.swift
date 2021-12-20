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
    
    @Published var status: CharacterStatus = .loading
    
    @Published var characters = [CharacterViewModel]()
    
    @Published var searchField: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var dataService = CharacterListDataService()
    
    let squadListVM: SquadListViewModel
    
    init(_ squadListVM: SquadListViewModel){
        self.squadListVM = squadListVM
        fetchCharacters()
        searchCharacters()
    }
    
    private func fetchCharacters(){
        self.status = .loading
        Task {
            await dataService.fetchCharacters()
            dataService.$characters.sink { charactersList in
                DispatchQueue.main.async {
                    self.status = .complete
                    self.characters = charactersList
                }
            }
            .store(in: &cancellables)
        }
    }
    
    private func searchCharacters(){
        self.status = .loading
        $searchField
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { value in
            if !(value.isEmpty){
                Task {
                    await self.dataService.searchCharacters(query: self.searchField)
                    self.dataService.$characters.sink { charactersList in
                        DispatchQueue.main.async {
                            self.status = .complete
                            self.characters = charactersList
                        }
                    }
                    .store(in: &self.cancellables)
                }
            }else{
                self.status = .complete
                self.fetchCharacters()
            }
        }
        .store(in: &cancellables)
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
            
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .complete:
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(viewModel.characters) { character in
                        NavigationLink {
                            CharacterDetailView(viewModel: CharacterDetailView.ViewModel(state: .user(character: character), SquadListViewModel(viewModel.squadListVM.squadListDataService)))
                        } label: {
                            CharacterListCellView(CharacterListCellView.ViewModel(character, viewModel.squadListVM))
                        }
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
        CharacterListView(viewModel: CharacterListViewModel(SquadListViewModel(SquadListDataService(controller: PersistenceController.shared))))
    }
}
