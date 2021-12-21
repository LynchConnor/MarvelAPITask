//
//  CharacterListDataService.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import CryptoKit
import Foundation

class CharacterListDataService {
    //MARK: Stores all characters from searches and general fetching.
    @Published var characters = [CharacterViewModel]()
    
    //MARK: Returns a hash string based on the Marvel api guidelines
    private func MD5(data: String) -> String {
        
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    //MARK: Fetches all characters based the offset (the number of characters it initially skips) and saves them to the published variable characters
    func fetchCharacters(offset: Int) async {
        
        let ts = String(Date().timeIntervalSince1970)
        
        let hash = MD5(data: "\(ts)\(privateKey)\(publicKey)")
        
        let urlString = "https://gateway.marvel.com:443/v1/public/characters?offset=\(offset)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedData = try JSONDecoder().decode(CharacterDataWrapper.self, from: data)
            
            DispatchQueue.main.async {
                self.characters.append(contentsOf: decodedData.data.results.compactMap(CharacterViewModel.init))
            }
        }catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    //MARK: Fetches characters based on whether the id matches the inputted id
    func fetchCharacter(id: String) async -> CharacterViewModel? {
        let idString = id.replacingOccurrences(of: " ", with: "")
        guard !(id.isEmpty && idString.isEmpty) else { return nil }
        
        let timestamp = String(Date().timeIntervalSince1970)
        let data = "\(timestamp)\(privateKey)\(publicKey)"
        let hash = MD5(data: data)
        
        guard let url: URL = URL(string: "https://gateway.marvel.com:443/v1/public/characters/\(id)?&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try? JSONDecoder().decode(CharacterDataWrapper.self, from: data)
            
            guard let result = decodedResponse?.data.results else { return nil }
            
            guard let character = result.map(CharacterViewModel.init).first  else { return nil }
            
            return character
            
        }catch {
            print("DEBUG: \(error.localizedDescription)")
            return nil
        }
    }
    
    //Searches characters based on whether the name in the database starts with the query
    func searchCharacters(query: String) async {
        
        let ts = String(Date().timeIntervalSince1970)
        
        let hash = MD5(data: "\(ts)\(privateKey)\(publicKey)")
        
        let queryString = query.replacingOccurrences(of: " ", with: "%20")
        
        let urlString = "https://gateway.marvel.com:443/v1/public/characters?nameStartsWith=\(queryString)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedData = try JSONDecoder().decode(CharacterDataWrapper.self, from: data)
            
            DispatchQueue.main.async {
                self.characters = decodedData.data.results.compactMap(CharacterViewModel.init)
            }
        }catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
}
