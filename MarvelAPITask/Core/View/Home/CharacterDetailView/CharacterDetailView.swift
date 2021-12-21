//
//  CharacterDetailView.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SDWebImageSwiftUI
import SwiftUI

enum CharacterState {
    case user(character: CharacterViewModel)
    case userId(id: String)
    case unknown
}

extension CharacterDetailView {
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var character: CharacterViewModel?
        
        let characterListDS = CharacterListDataService()
        
        let squadListVM: SquadListViewModel
        
        init(state: CharacterState, _ squadListVM: SquadListViewModel){
            self.squadListVM = squadListVM
            switch state {
            case .user(let character):
                self.character = character
                self.character?.isRecruited = checkRecruitmentStatus
            case .userId(let id):
                Task {
                    self.character = await characterListDS.fetchCharacter(id: id)
                    self.character?.isRecruited = checkRecruitmentStatus
                }
            case .unknown:
                return
            }
        }
        
        var checkRecruitmentStatus: Bool {
            guard let id = character?.id else { return false }
            return squadListVM.squadEntities.contains(where: { $0.characterId == id })
        }
        
        var isRecruited: Bool {
            return character?.isRecruited ?? false
        }
        
        var foreground: Color {
            return isRecruited ? .red : .black
        }
        
        var background: Color {
            return isRecruited ? .white : .white
        }
        
        var textString: String {
            return isRecruited ? "FIRE" : "RECRUIT"
        }
        
        var imageString: String {
            return isRecruited ? "minus.circle.fill" : "plus.circle.fill"
        }
        
        func action(completion: @escaping () -> ()){
            isRecruited ? fireCharacter() : recruitCharacter()
            if !(isRecruited) {
                completion()
            }
        }
        
        private func recruitCharacter(){
            guard let character = character else { return }
            squadListVM.recruitCharacter(character: character) {
                self.character?.isRecruited = true
            }
        }
        
        private func fireCharacter(){
            guard let id = character?.id else { return }
            squadListVM.fireCharacter(id: id)
            self.character?.isRecruited = nil
        }
    }
}

struct CharacterDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            
            if let character = viewModel.character {
                
                VStack(alignment: .leading) {
                    
                    StretchingHeader(height: 200) {
                        
                        WebImage(url: character.imageURL)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(character.name)
                            .foregroundColor(.primary)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(character.description)
                            .foregroundColor(.secondary)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Button {
                            viewModel.action() {
                                dismiss()
                            }
                        } label: {
                            
                            HStack {
                                
                                Text(viewModel.textString)
                                    .font(.title2)
                                    .bold()
                                
                                Image(systemName: viewModel.imageString)
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .scaledToFit()
                                
                            }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 25)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.75))
                                .cornerRadius(10)
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            else {
                ProgressView() //i love u
            }
        }
    }
}

struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailView(viewModel: CharacterDetailView.ViewModel(state: .unknown, SquadListViewModel(PersistenceController.shared)))
    }
}
