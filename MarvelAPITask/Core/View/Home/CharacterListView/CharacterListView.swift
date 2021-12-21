//
//  CharacterListView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SDWebImageSwiftUI
import SwiftUI

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
