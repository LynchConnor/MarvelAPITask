//
//  HomeView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    
    @StateObject var squadListVM: SquadListViewModel
    
    init(squadListVM: SquadListViewModel){
        _squadListVM = StateObject(wrappedValue: squadListVM)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                
                if squadListVM.squadHeaderIsVisible {
                    
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
            HomeView(squadListVM: SquadListViewModel(PersistenceController.shared))
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}
