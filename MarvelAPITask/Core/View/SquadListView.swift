//
//  SquadListView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SDWebImageSwiftUI
import SwiftUI

struct SquadListView: View {
    
    @ObservedObject var squadListVM: SquadListViewModel
    
    var remaining: Int {
        return 5-squadListVM.squadEntities.count
    }
    
    init(squadListViewModel: SquadListViewModel){
        _squadListVM = ObservedObject(wrappedValue: squadListViewModel)
    }
    
    var body: some View {
        LazyHStack(spacing: 10) {
            ForEach(squadListVM.squadEntities) { character in

                VStack {
                    NavigationLink {
                        if let id = character.characterId {
                            LazyView(CharacterDetailView(viewModel: CharacterDetailView.ViewModel(state: .userId(id: id), squadListVM)))
                        }
                    } label: {
                        VStack {
                            WebImage(url: URL(string: character.imageURLString!))
                                .resizable()
                                .frame(width: 70, height: 70, alignment: .center)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(Circle())
                            
                            Text(character.name?.prefix(10) ?? "")
                                .font(.system(size: 13, weight: .regular))
                                .frame(width: 70)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
                    }
                    .overlay(
                        Button {
                            if let id = character.characterId {
                                squadListVM.fireCharacter(id: id)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                        }
                            .offset(x: 5, y: -5)
                        ,alignment: .topTrailing
                    )
                }
            }
            
            if remaining > 0 {
                ForEach(1...remaining, id: \.self) { item in
                    VStack {
                        Circle()
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 70, height: 70, alignment: .center)
                        
                        Text("Name")
                            .frame(width: 70)
                    }
                    .redacted(reason: .placeholder)
                }
            }
        }
        .padding(.horizontal, 15)
    }
}

struct SquadListView_Previews: PreviewProvider {
    static var previews: some View {
        SquadListView(squadListViewModel: SquadListViewModel(SquadListDataService(controller: PersistenceController.shared)))
    }
}
