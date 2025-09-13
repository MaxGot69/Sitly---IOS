import Foundation
import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - LocationServiceProtocol
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            
            // Проверяем разрешения
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                // Если разрешение есть, получаем местоположение
                locationManager.requestLocation()
            case .denied, .restricted:
                continuation.resume(returning: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176))
            case .notDetermined:
                // Запрашиваем разрешение
                locationManager.requestWhenInUseAuthorization()
                // Имитируем получение местоположения для MVP
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    continuation.resume(returning: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176))
                }
            @unknown default:
                continuation.resume(returning: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176))
            }
        }
    }
    
    func requestLocationPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                continuation.resume(returning: true)
            case .denied, .restricted:
                continuation.resume(returning: false)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                // Имитируем разрешение для MVP
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    continuation.resume(returning: true)
                }
            @unknown default:
                continuation.resume(returning: false)
            }
        }
    }
    
    func startLocationUpdates() {
        // В реальном приложении здесь был бы запуск обновлений местоположения
        print("📍 LocationService: Started location updates")
    }
    
    func stopLocationUpdates() {
        // В реальном приложении здесь был бы останов обновлений местоположения
        print("📍 LocationService: Stopped location updates")
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Обновляем каждые 10 метров
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Для MVP просто возвращаем дефолтные координаты
        locationContinuation?.resume(returning: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176))
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 LocationService: Location permission granted")
        case .denied, .restricted:
            print("📍 LocationService: Location permission denied")
        case .notDetermined:
            print("📍 LocationService: Location permission not determined")
        @unknown default:
            print("📍 LocationService: Unknown authorization status")
        }
    }
}

// MARK: - Location Error

enum LocationError: LocalizedError {
    case permissionDenied
    case locationError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Доступ к местоположению запрещен"
        case .locationError(let error):
            return "Ошибка получения местоположения: \(error.localizedDescription)"
        case .unknown:
            return "Неизвестная ошибка местоположения"
        }
    }
}
