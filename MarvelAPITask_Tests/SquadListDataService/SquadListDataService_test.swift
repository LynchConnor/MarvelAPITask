//
//  SquadListDataService_test.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

import CoreData
import Combine
import XCTest
@testable import MarvelAPITask

//Naming Structure: test_[struct or class]_[variable or function]_[expected result]

class SquadListDataService_test: XCTestCase {

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
    
    func test_SquadListDataService_fetchSquad_shouldReturnEmpty(){
        //Given
        let squadDataService = SquadListDataService(controller: PersistenceController(.inMemory))
        
        XCTAssertEqual(squadDataService.squadList.count, 0)
    }
    
    func test_SquadListDataService_fetchSquad_shouldReturnValue(){
        //Given
        let squadDataService = SquadListDataService(controller: PersistenceController(.inMemory))
        
        //Then
        let character: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        let characterVM: CharacterViewModel = CharacterViewModel(character: character)
        
        let expectation = XCTestExpectation(description: "Should returns items within 5 seconds.")
        
        squadDataService.$squadList.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        squadDataService.saveCharacter(character: characterVM)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(squadDataService.squadList.count, 1)
    }
    
    func test_SquadListDataService_fetchSquad_shouldReturnMultipleValues(){
        //Given
        let squadDataService = SquadListDataService(controller: PersistenceController(.inMemory))
        
        //Then
        let character: Character = Character(id: 1011334, name: "3-D Man", description: "", thumbnail: CharacterImage(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        let characterVM: CharacterViewModel = CharacterViewModel(character: character)
        
        let expectation = XCTestExpectation(description: "Should returns items within 5 seconds.")
        
        squadDataService.$squadList.sink { squadList in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        squadDataService.saveCharacter(character: characterVM)
        squadDataService.saveCharacter(character: characterVM)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(squadDataService.squadList.count, 2)
    }

}
