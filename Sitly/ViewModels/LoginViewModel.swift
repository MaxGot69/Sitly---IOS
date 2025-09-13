import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showRegistration = false
    
    // MARK: - Private Properties
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Initialization
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Public Methods
    
    func login(email: String, password: String, rememberMe: Bool) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await userUseCase.login(
                email: email,
                password: password,
                rememberMe: rememberMe
            )
            
            isLoading = false
            return success
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func sendPasswordReset(email: String) {
        Task {
            do {
                let success = try await userUseCase.sendPasswordResetEmail(email: email)
                if success {
                    // Показываем уведомление об успешной отправке
                    print("✅ Email для восстановления пароля отправлен")
                }
            } catch {
                errorMessage = "Ошибка отправки email: \(error.localizedDescription)"
            }
        }
    }
    
    func showRegistrationScreen() {
        showRegistration = true
    }
}



