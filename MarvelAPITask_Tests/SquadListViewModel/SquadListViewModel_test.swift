//
//  SquadListViewModel_test.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

import XCTest
import Combine
@testable import MarvelAPITask

class SquadListViewModel_test: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_SquadListViewModel_fetchSquad_shouldReturnEmpty(){
        //Given
        let squadListVM = SquadListViewModel(PersistenceController(.inMemory))
        
        let expectation = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        //When
        squadListVM.$squadEntities.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        squadListVM.fetchSquad()
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(squadListVM.squadEntities, [])
    }
    
    func test_SquadListViewModel_fetchSquad_shouldReturnValues(){
        //Given
        let squadListVM = SquadListViewModel(PersistenceController(.inMemory))
        
        let expectation = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        //When
        squadListVM.$squadEntities.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        let character: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        
        squadListVM.recruitCharacter(character: CharacterViewModel(character: character)) {
            squadListVM.fetchSquad()
        }
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(squadListVM.squadEntities.count, 0)
    }
    
    func test_SquadListViewModel_fetchSquad_shouldReturnOneCharacter(){
        //Given
        let squadListVM = SquadListViewModel(PersistenceController(.inMemory))
        
        let expectation = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        //When
        squadListVM.$squadEntities.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        let character: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        
        let character2: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        
        squadListVM.recruitCharacter(character: CharacterViewModel(character: character)) {
            squadListVM.recruitCharacter(character: CharacterViewModel(character: character2)) {
                squadListVM.fetchSquad()
            }
        }
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(squadListVM.squadEntities.count, 1)
    }
    
    func test_SquadListViewModel_fetchSquad_shouldReturnTwoCharacters(){
        //Given
        let squadListVM = SquadListViewModel(PersistenceController(.inMemory))
        
        let expectation = XCTestExpectation(description: "Should take less than 5 seconds.")
        
        //When
        squadListVM.$squadEntities.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        let character: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        
        let character2: Character = Character(id: 1017100, name: "A-Bomb (HAS)", description: "Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16", extension: "jpg"))
        
        squadListVM.recruitCharacter(character: CharacterViewModel(character: character)) {
            squadListVM.recruitCharacter(character: CharacterViewModel(character: character2)) {
                squadListVM.fetchSquad()
            }
        }
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(squadListVM.squadEntities.count, 2)
    }

}
