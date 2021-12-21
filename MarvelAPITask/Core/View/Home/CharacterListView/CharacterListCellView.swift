//
//  CharacterListCell.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//
import Combine
import SDWebImageSwiftUI
import SwiftUI

extension CharacterListCellView {
    class ViewModel: ObservableObject {
        @Published var character: CharacterViewModel
        
        private var cancellables = Set<AnyCancellable>()
        
        let squadListVM: SquadListViewModel
        
        init(_ character: CharacterViewModel, _ squadListVM: SquadListViewModel){
            self.squadListVM = squadListVM
            self.character = character
            checkRecruitmentStatus()
        }
        
        func checkRecruitmentStatus(){
            
            squadListVM.$squadEntities
                .sink { squad in
                    self.character.isRecruited = squad.contains(where: { $0.characterId == self.character.id })
            }
                .store(in: &cancellables)
        }
        
        var isRecruited: Bool {
            return character.isRecruited ?? false
        }
        
        var foreground: Color {
            return isRecruited ? .red : .black
        }
        
        var background: Color {
            return isRecruited ? .white : .white
        }
        
        var imageString: String {
            return isRecruited ? "minus.circle.fill" : "plus.circle.fill"
        }
        
        func action(){
            isRecruited ? fireCharacter() : recruitCharacter()
        }
        
        private func recruitCharacter(){
            squadListVM.recruitCharacter(character: character) {
                self.character.isRecruited = true
            }
        }
        
        private func fireCharacter(){
            squadListVM.fireCharacter(id: character.id)
            self.character.isRecruited = nil
        }
    }
}

struct CharacterListCellView: View {
    
    @StateObject var viewModel: CharacterListCellView.ViewModel
    
    init(_ viewModel: CharacterListCellView.ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            WebImage(url: viewModel.character.imageURL)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    LinearGradient(colors: [.clear, .clear, .black.opacity(0.25), .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                )
            
            HStack(alignment: .bottom) {
            
            Text(viewModel.character.name)
                    .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 0)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
             
                
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
                
            }
            .padding(10)
        }
        .overlay(
                
                Button(action: {
                    viewModel.action()
                }, label: {
                    Image(systemName: viewModel.imageString)
                        .resizable()
                        .frame(width: 45, height: 45, alignment: .center)
                        .scaledToFit()
                        .foregroundColor(viewModel.foreground)
                        .background(viewModel.background)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(viewModel.background,  lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
                        .transition(.flipFromBottom)
                })
                .padding(10)
                ,alignment: .topTrailing
        )
        .cornerRadius(10)
    }
}

struct CharacterListCellView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListCellView(CharacterListCellView.ViewModel(characterExample, SquadListViewModel(PersistenceController.shared)))
    }
}
