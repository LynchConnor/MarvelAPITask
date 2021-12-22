//
//  CharacterListViewModel_test.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

import XCTest
import Combine
@testable import MarvelAPITask

class CharacterListViewModel_test: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellables.removeAll()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_CharacterListViewModel_fetchCharacters_fetchCharactersNotEmpty(){
        let characterListVM = CharacterListViewModel(SquadListViewModel(PersistenceController(.inMemory)))
        //When
        
        let exception = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        characterListVM.$characters
            .dropFirst()
            .sink { characterList in
            exception.fulfill()
        }
        .store(in: &cancellables)
        
        //Then
        wait(for: [exception], timeout: 5)
        XCTAssertGreaterThan(characterListVM.characters.count, 0)
    }
    
    func test_CharacterListViewModel_fetchCharacters_searchNotEmpty(){
        let characterListVM = CharacterListViewModel(SquadListViewModel(PersistenceController(.inMemory)))
        //When
        
        let exception = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        characterListVM.$characters
            .dropFirst()
            .sink { characterList in
            exception.fulfill()
        }
        .store(in: &cancellables)
        
        characterListVM.searchField = "Spider-Man"
        
        //Then
        wait(for: [exception], timeout: 5)
        XCTAssertGreaterThan(characterListVM.characters.count, 0)
    }
    
    func test_CharacterListViewModel_fetchCharacters_searchEmpty(){
        let characterListVM = CharacterListViewModel(SquadListViewModel(PersistenceController(.inMemory)))
        //When
        
        let exception = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        characterListVM.$characters
            .dropFirst()
            .sink { characterList in
            exception.fulfill()
        }
        .store(in: &cancellables)
        
        characterListVM.searchField = " "
        
        //Then
        wait(for: [exception], timeout: 5)
        XCTAssertEqual(characterListVM.characters.count, 0)
    }

}
