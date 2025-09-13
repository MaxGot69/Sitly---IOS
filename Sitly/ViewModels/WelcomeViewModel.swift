import Foundation
import SwiftUI

@MainActor
final class WelcomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showLogin = false
    @Published var showRegistration = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Initialization
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Public Methods
    
    func showLoginScreen() {
        showLogin = true
    }
    
    func showRegistrationScreen() {
        showRegistration = true
    }
    
    func skipAuthentication() {
        // Для MVP пока не реализуем демо режим
        errorMessage = "Демо режим не реализован в MVP версии"
    }
}
