import UIKit

// MARK: - Haptic Service

final class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func lightImpact() {
        impact(.light)
    }
    
    func mediumImpact() {
        impact(.medium)
    }
    
    func heavyImpact() {
        impact(.heavy)
    }
    
    // MARK: - Notification Feedback
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func success() {
        notification(.success)
    }
    
    func warning() {
        notification(.warning)
    }
    
    func error() {
        notification(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Custom Patterns
    
    func bookingSuccess() {
        // Последовательность для успешного бронирования
        DispatchQueue.main.async {
            self.lightImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mediumImpact()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.success()
                }
            }
        }
    }
    
    func buttonPress() {
        // Легкая вибрация для нажатий кнопок
        lightImpact()
    }
    
    func cardTap() {
        // Средняя вибрация для нажатий карточек
        mediumImpact()
    }
    
    func swipeAction() {
        // Селекция для свайпов
        selection()
    }
    
    func aiRecommendation() {
        // Особый паттерн для AI рекомендаций
        DispatchQueue.main.async {
            self.selection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.lightImpact()
            }
        }
    }
    
    func searchFound() {
        // Вибрация когда найдены результаты поиска
        DispatchQueue.main.async {
            self.lightImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.lightImpact()
            }
        }
    }
    
    func authSuccess() {
        // Успешная авторизация
        DispatchQueue.main.async {
            self.mediumImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.success()
            }
        }
    }
    
    func authError() {
        // Ошибка авторизации
        DispatchQueue.main.async {
            self.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.heavyImpact()
            }
        }
    }
}

// MARK: - SwiftUI Extensions

import SwiftUI

extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            HapticService.shared.impact(style)
        }
    }
    
    func hapticSuccess() -> some View {
        self.onAppear {
            HapticService.shared.success()
        }
    }
    
    func hapticError() -> some View {
        self.onAppear {
            HapticService.shared.error()
        }
    }
    
    func hapticButtonPress() -> some View {
        self.onTapGesture {
            HapticService.shared.buttonPress()
        }
    }
    
    func hapticCardTap() -> some View {
        self.onTapGesture {
            HapticService.shared.cardTap()
        }
    }
}
