import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Network Service Implementation

final class NetworkService: NetworkServiceProtocol {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    init() {
        // Firebase уже должен быть настроен в проекте
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        switch endpoint {
        case let firebaseEndpoint as FirebaseEndpoint:
            return try await handleFirebaseRequest(firebaseEndpoint)
        default:
            throw RepositoryError.serverError("Неподдерживаемый тип endpoint")
        }
    }
    
    func upload<T: Codable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T {
        // Для MVP пока не реализуем upload
        throw RepositoryError.serverError("Upload не реализован в MVP версии")
    }
    
    // MARK: - Firebase Methods
    
    private func handleFirebaseRequest<T: Codable>(_ endpoint: FirebaseEndpoint) async throws -> T {
        switch endpoint {
        case .getRestaurants:
            let snapshot = try await db.collection("restaurants").getDocuments()
            let restaurants = try snapshot.documents.compactMap { document -> Restaurant? in
                let data = document.data()
                var restaurantData = data
                restaurantData["id"] = document.documentID
                
                // Преобразуем координаты
                if let geoPoint = data["coordinate"] as? GeoPoint {
                    restaurantData["latitude"] = geoPoint.latitude
                    restaurantData["longitude"] = geoPoint.longitude
                    restaurantData.removeValue(forKey: "coordinate")
                }
                
                // Конвертируем Firebase Timestamp в строку
                if let createdAt = restaurantData["createdAt"] as? Timestamp {
                    restaurantData["createdAt"] = ISO8601DateFormatter().string(from: createdAt.dateValue())
                }
                if let updatedAt = restaurantData["updatedAt"] as? Timestamp {
                    restaurantData["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt.dateValue())
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: restaurantData)
                return try JSONDecoder().decode(Restaurant.self, from: jsonData)
            }
            return restaurants as! T
            
        case .getRestaurant(let id):
            let document = try await db.collection("restaurants").document(id).getDocument()
            guard let data = document.data() else {
                throw RepositoryError.notFound
            }
            
            var restaurantData = data
            restaurantData["id"] = document.documentID
            
            if let geoPoint = data["coordinate"] as? GeoPoint {
                restaurantData["latitude"] = geoPoint.latitude
                restaurantData["longitude"] = geoPoint.longitude
                restaurantData.removeValue(forKey: "coordinate")
            }
            
            // Конвертируем Firebase Timestamp в строку
            if let createdAt = restaurantData["createdAt"] as? Timestamp {
                restaurantData["createdAt"] = ISO8601DateFormatter().string(from: createdAt.dateValue())
            }
            if let updatedAt = restaurantData["updatedAt"] as? Timestamp {
                restaurantData["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt.dateValue())
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: restaurantData)
            return try JSONDecoder().decode(Restaurant.self, from: jsonData) as! T
            
        case .searchRestaurants(let query):
            let snapshot = try await db.collection("restaurants")
                .whereField("searchKeywords", arrayContains: query.lowercased())
                .getDocuments()
            
            let restaurants = try snapshot.documents.compactMap { document -> Restaurant? in
                let data = document.data()
                var restaurantData = data
                restaurantData["id"] = document.documentID
                
                if let geoPoint = data["coordinate"] as? GeoPoint {
                    restaurantData["latitude"] = geoPoint.latitude
                    restaurantData["longitude"] = geoPoint.longitude
                    restaurantData.removeValue(forKey: "coordinate")
                }
                
                // Конвертируем Firebase Timestamp в строку
                if let createdAt = restaurantData["createdAt"] as? Timestamp {
                    restaurantData["createdAt"] = ISO8601DateFormatter().string(from: createdAt.dateValue())
                }
                if let updatedAt = restaurantData["updatedAt"] as? Timestamp {
                    restaurantData["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt.dateValue())
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: restaurantData)
                return try JSONDecoder().decode(Restaurant.self, from: jsonData)
            }
            return restaurants as! T
            
        case .getUserBookings(let userId):
            let snapshot = try await db.collection("bookings")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()
            
            let bookings = try snapshot.documents.compactMap { document -> Booking? in
                let data = document.data()
                var bookingData = data
                bookingData["id"] = document.documentID
                
                let jsonData = try JSONSerialization.data(withJSONObject: bookingData)
                return try JSONDecoder().decode(Booking.self, from: jsonData)
            }
            return bookings as! T
            
        case .createBooking(let booking):
            let bookingData = try JSONEncoder().encode(booking)
            let bookingDict = try JSONSerialization.jsonObject(with: bookingData) as? [String: Any] ?? [:]
            
            // Преобразуем координаты для Firestore
            var firestoreData = bookingDict
            firestoreData.removeValue(forKey: "id") // Убираем ID, Firestore создаст сам
            
            _ = try await db.collection("bookings").addDocument(data: firestoreData)
            
            let newBooking = booking
            // Создаем новый объект с ID от Firestore
            let newBookingData = try JSONEncoder().encode(newBooking)
            return try JSONDecoder().decode(Booking.self, from: newBookingData) as! T
            
        case .getRestaurantReviews(let restaurantId):
            let snapshot = try await db.collection("reviews")
                .whereField("restaurantId", isEqualTo: restaurantId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let reviews = try snapshot.documents.compactMap { document -> Review? in
                let data = document.data()
                var reviewData = data
                reviewData["id"] = document.documentID
                
                let jsonData = try JSONSerialization.data(withJSONObject: reviewData)
                return try JSONDecoder().decode(Review.self, from: jsonData)
            }
            return reviews as! T
            
        case .createReview(let review):
            let reviewData = try JSONEncoder().encode(review)
            let reviewDict = try JSONSerialization.jsonObject(with: reviewData) as? [String: Any] ?? [:]
            
            var firestoreData = reviewDict
            firestoreData.removeValue(forKey: "id")
            
            _ = try await db.collection("reviews").addDocument(data: firestoreData)
            
            let newReview = review
            let newReviewData = try JSONEncoder().encode(newReview)
            return try JSONDecoder().decode(Review.self, from: newReviewData) as! T
        }
    }
}

// MARK: - Firebase Endpoints

enum FirebaseEndpoint: APIEndpoint {
    case getRestaurants
    case getRestaurant(String)
    case searchRestaurants(String)
    case getUserBookings(UUID)
    case createBooking(Booking)
    case getRestaurantReviews(String)
    case createReview(Review)
    
    var path: String {
        switch self {
        case .getRestaurants:
            return "/restaurants"
        case .getRestaurant(let id):
            return "/restaurants/\(id)"
        case .searchRestaurants:
            return "/restaurants/search"
        case .getUserBookings:
            return "/bookings"
        case .createBooking:
            return "/bookings"
        case .getRestaurantReviews:
            return "/reviews"
        case .createReview:
            return "/reviews"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getRestaurants, .getRestaurant, .searchRestaurants, .getUserBookings, .getRestaurantReviews:
            return .GET
        case .createBooking, .createReview:
            return .POST
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
} 