//
//  CharacterModels.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import Foundation

struct CharacterDataWrapper: Codable {
    let data: CharacterDataContainer
}

struct CharacterDataContainer: Codable {
    let results: [Character]
}

struct Character: Codable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: CharacterImage
}

struct CharacterImage: Codable {
    let path: String
    let `extension`: String
}

struct CharacterViewModel: Identifiable, Codable, Equatable {
    
    init(character: Character){
        self.id = String(character.id)
        self.name = character.name
        self.description = character.description
        let imagePath = character.thumbnail.path.replacingOccurrences(of: "http", with: "https")
        self.imageURLString = "\(imagePath).\(character.thumbnail.extension)"
    }
    
    let id: String
    let name: String
    let description: String
    let imageURLString: String
    var imageURL: URL? {
        return URL(string: imageURLString)
    }
    
    var isRecruited: Bool?
}
