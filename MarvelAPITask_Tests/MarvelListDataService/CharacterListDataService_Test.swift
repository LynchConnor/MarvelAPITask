//
//  CharacterListDataService_Test.swift
//  MarvelAPITask_Tests
//
//  Created by Connor A Lynch on 21/12/2021.
//

@testable import MarvelAPITask
import Combine
import XCTest

class CharacterListDataService_Test: XCTestCase {
    
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
    
    func test_CharacterListDataService_fetchCharacters_shouldReturnItems() async{
        // Given
        let vm = CharacterListDataService()
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        var items: [CharacterViewModel] = []
        
        vm.$characters.sink { characters in
            items = characters
            expectation.fulfill()
            
        }
        .store(in: &cancellables)
        
        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(vm.characters, items)
    }
    
    func test_CharacterListDataService_fetchCharacter_shouldNotReturnItem() async{
        // Given
        let vm = CharacterListDataService()
        
        // When
        let character = await vm.fetchCharacter(id: "")
        
        //Then
        XCTAssertNil(character)
    }
    
    func test_CharacterListDataService_fetchCharacter_shouldReturnItem() async{
        //MARK: Given
        let vm = CharacterListDataService()
        
        //MARK: When
        
        // Spiderman id for (Spider-Man (1602))
        let id = "1011054"
        
        let character = await vm.fetchCharacter(id: id)
        
        //MARK: Then
        XCTAssertNotNil(character)
    }
    
    func test_CharacterListDataService_searchCharacter_shouldNotReturnItems() async {
        //MARK: Given
        let vm = CharacterListDataService()
        
        //MARK: When
        
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        await vm.searchCharacters(query: " ")
        
        vm.$characters.sink { characters in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        //MARK: Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(vm.characters, [])
    }
    
    func test_CharacterListDataService_searchCharacter_notNil() async {
        //MARK: Given
        let vm = CharacterListDataService()
        
        //MARK: When
        
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        await vm.searchCharacters(query: "Spider-Man")
        
        vm.$characters.sink { characters in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        //MARK: Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(vm.characters)
    }

}
