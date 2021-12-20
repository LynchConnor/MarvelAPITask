//
//  HomeView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

class SquadListViewModel: ObservableObject {
    @Published var squadEntities = [SquadEntity]()
    
    let squadMaxCount: Int = 5
    
    let squadListDataService: SquadListDataService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ squadListDS: SquadListDataService){
        self.squadListDataService = squadListDS
        fetchSquad()
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

struct HomeView: View {
    
    @StateObject var squadListVM: SquadListViewModel
    
    init(squadListVM: SquadListViewModel){
        _squadListVM = StateObject(wrappedValue: squadListVM)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                
                if squadListVM.squadCount < squadListVM.squadMaxCount {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("Pick wisely ( + to recruit)( - to fire)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.gray)
                    
                        Text("\(squadListVM.squadRemaining) out of \(squadListVM.squadMaxCount) squad members remaning...")
                            .font(.headline)
                    }
                    .padding(.leading, 20)
                }
                
                ScrollView(.horizontal, showsIndicators: false){
                    
                    SquadListView(squadListViewModel: squadListVM)
                }
                .frame(height: 120, alignment: .top)
                .padding(.vertical, 10)
                
                CharacterListView(viewModel: CharacterListViewModel(squadListVM))
                
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Marvel Squad Creator")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(squadListVM: SquadListViewModel(SquadListDataService(controller: PersistenceController.shared)))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}
