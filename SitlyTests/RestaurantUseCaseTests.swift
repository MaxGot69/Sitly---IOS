import XCTest
@testable import Sitly

final class RestaurantUseCaseTests: XCTestCase {
    var sut: RestaurantUseCase!
    var mockRepository: MockRestaurantRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockRestaurantRepository()
        sut = RestaurantUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Get Restaurants Tests
    
    func testGetRestaurants_WhenSuccessful_ReturnsRestaurants() async throws {
        // Given
        let expectedRestaurants = [
            Restaurant(
                name: "Test Restaurant",
                cuisine: "Italian",
                rating: 4.5,
                description: "Test description",
                imageNames: ["test"],
                address: "Test Address",
                workHours: "10:00-22:00",
                averageCheck: 1000,
                coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                availableTables: 5
            )
        ]
        mockRepository.mockRestaurants = expectedRestaurants
        
        // When
        let restaurants = try await sut.getRestaurants()
        
        // Then
        XCTAssertEqual(restaurants.count, 1)
        XCTAssertEqual(restaurants.first?.name, "Test Restaurant")
    }
    
    func testGetRestaurants_WhenRepositoryThrowsError_ThrowsError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When & Then
        do {
            _ = try await sut.getRestaurants()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
    
    // MARK: - Search Restaurants Tests
    
    func testSearchRestaurants_WithValidQuery_ReturnsFilteredRestaurants() async throws {
        // Given
        let query = "Italian"
        let expectedRestaurants = [
            Restaurant(
                name: "Italian Restaurant",
                cuisine: "Italian",
                rating: 4.5,
                description: "Italian cuisine",
                imageNames: ["italian"],
                address: "Italian Address",
                workHours: "10:00-22:00",
                averageCheck: 1500,
                coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                availableTables: 3
            )
        ]
        mockRepository.mockRestaurants = expectedRestaurants
        
        // When
        let restaurants = try await sut.searchRestaurants(query: query)
        
        // Then
        XCTAssertEqual(restaurants.count, 1)
        XCTAssertEqual(restaurants.first?.cuisine, "Italian")
    }
    
    func testSearchRestaurants_WithEmptyQuery_ThrowsValidationError() async {
        // Given
        let query = ""
        
        // When & Then
        do {
            _ = try await sut.searchRestaurants(query: query)
            XCTFail("Expected validation error to be thrown")
        } catch {
            XCTAssertTrue(error is UseCaseError)
        }
    }
    
    func testSearchRestaurants_WithWhitespaceQuery_ThrowsValidationError() async {
        // Given
        let query = "   "
        
        // When & Then
        do {
            _ = try await sut.searchRestaurants(query: query)
            XCTFail("Expected validation error to be thrown")
        } catch {
            XCTAssertTrue(error is UseCaseError)
        }
    }
}

// MARK: - Mock Repository

final class MockRestaurantRepository: RestaurantRepositoryProtocol {
    var mockRestaurants: [Restaurant] = []
    var shouldThrowError = false
    
    func fetchRestaurants() async throws -> [Restaurant] {
        if shouldThrowError {
            throw RepositoryError.networkError(URLError(.badServerResponse))
        }
        return mockRestaurants
    }
    
    func fetchRestaurant(by id: String) async throws -> Restaurant {
        if shouldThrowError {
            throw RepositoryError.notFound
        }
        return mockRestaurants.first ?? Restaurant(
            name: "Mock Restaurant",
            cuisine: "Mock",
            rating: 4.0,
            description: "Mock description",
            imageNames: ["mock"],
            address: "Mock Address",
            workHours: "10:00-22:00",
            averageCheck: 1000,
            coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
            availableTables: 5
        )
    }
    
    func searchRestaurants(query: String) async throws -> [Restaurant] {
        if shouldThrowError {
            throw RepositoryError.networkError(URLError(.badServerResponse))
        }
        return mockRestaurants.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.cuisine.localizedCaseInsensitiveContains(query) }
    }
    
    func fetchRestaurantsByCuisine(_ cuisine: String) async throws -> [Restaurant] {
        if shouldThrowError {
            throw RepositoryError.networkError(URLError(.badServerResponse))
        }
        return mockRestaurants.filter { $0.cuisine == cuisine }
    }
    
    func fetchNearbyRestaurants(latitude: Double, longitude: Double, radius: Double) async throws -> [Restaurant] {
        if shouldThrowError {
            throw RepositoryError.networkError(URLError(.badServerResponse))
        }
        return mockRestaurants
    }
} 