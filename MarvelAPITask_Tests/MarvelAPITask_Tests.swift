//
//  MarvelAPITask_Tests.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

@testable import MarvelAPITask
import XCTest
import Combine

class MarvelAPITask_Tests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: Test to see if the character list view model returns list of characters on app init
    func test_CharacterListViewModel_fetchCharacters_shouldReturnItems(){
        // Given
        let vm = CharacterListViewModel(SquadListViewModel(PersistenceController.shared))
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        vm.$characters
            .dropFirst()
            .sink { characters in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(vm.characters.count, 10)
    }
    
    func test_SquadListViewModel_fetchSquad_shouldReturnEmpty(){
        // Given
        let vm = SquadListViewModel(PersistenceController.shared)
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
    }
    
}
