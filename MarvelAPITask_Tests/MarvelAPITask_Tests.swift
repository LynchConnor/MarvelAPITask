//
//  MarvelAPITask_Tests.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

@testable import MarvelAPITask
import XCTest
import Combine

//Naming Structure: test_[struct or class]_[variable or function]_[expected result]

class MarvelAPITask_Tests: XCTestCase {
    
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
        measure {
            test_CharacterListViewModel_fetchCharacters_shouldReturnItems()
        }
    }
    
    //MARK: Test to see if the character list view model returns list of characters on app init
    func test_CharacterListViewModel_fetchCharacters_shouldReturnItems(){
        // Given
        let vm = CharacterListViewModel(SquadListViewModel(PersistenceController.shared))
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        var items: [CharacterViewModel] = []
        
        vm.$characters
            .sink { characters in
                items = characters
                expectation.fulfill()
        }
        .store(in: &cancellables)
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(vm.characters, items)
    }
    
}
