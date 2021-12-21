//
//  CharacterListDataService.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import CryptoKit
import Foundation

class CharacterListDataService {
    @Published var characters = [CharacterViewModel]()
    
    private func MD5(data: String) -> String {
        
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
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
    
    func fetchCharacter(id: String) async -> CharacterViewModel? {
        let timestamp = String(Date().timeIntervalSince1970)
        let data = "\(timestamp)\(privateKey)\(publicKey)"
        let hash = MD5(data: data)
        
        let url: String = "https://gateway.marvel.com:443/v1/public/characters/\(id)?&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            
            let decodedResponse = try? JSONDecoder().decode(CharacterDataWrapper.self, from: data)
            
            guard let result = decodedResponse?.data.results else { return nil }
            
            guard let character = result.map(CharacterViewModel.init).first  else { return nil }
            
            return character
            
        }catch {
            print("DEBUG: \(error.localizedDescription)")
            return nil
        }
    }
    
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
