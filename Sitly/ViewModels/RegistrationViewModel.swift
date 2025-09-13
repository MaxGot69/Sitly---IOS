import Foundation
import SwiftUI

@MainActor
final class RegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Initialization
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Public Methods
    
    func register(email: String, password: String, name: String) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await userUseCase.register(
                email: email,
                password: password,
                name: name
            )
            
            isLoading = false
            return success
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
