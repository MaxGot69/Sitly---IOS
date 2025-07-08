import Foundation
import MapKit

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let cuisine: String
    let address: String
    let rating: Double
    let imageName: String
    let coordinate: CLLocationCoordinate2D
    let latitude: Double
    let longitude: Double
    
    init(name: String, cuisine: String, address: String, rating: Double, imageName: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.cuisine = cuisine
        self.address = address
        self.rating = rating
        self.imageName = imageName
        self.coordinate = coordinate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
