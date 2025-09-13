import Foundation

final class ReviewUseCase: ReviewUseCaseProtocol {
    private let repository: ReviewRepositoryProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    
    init(repository: ReviewRepositoryProtocol, restaurantRepository: RestaurantRepositoryProtocol) {
        self.repository = repository
        self.restaurantRepository = restaurantRepository
    }
    
    // MARK: - Review Methods
    
    func createReview(
        restaurantId: String,
        userId: String,
        rating: Double,
        text: String,
        photos: [String]?
    ) async throws -> Review {
        // Валидация рейтинга
        guard rating >= 1.0 && rating <= 5.0 else {
            throw UseCaseError.businessLogicError("Рейтинг должен быть от 1 до 5")
        }
        
        // Валидация текста отзыва
        guard text.count >= 10 else {
            throw UseCaseError.businessLogicError("Отзыв должен содержать минимум 10 символов")
        }
        
        guard text.count <= 1000 else {
            throw UseCaseError.businessLogicError("Отзыв не может превышать 1000 символов")
        }
        
        // Проверяем, что ресторан существует
        _ = try await restaurantRepository.fetchRestaurant(by: restaurantId)
        
        // Проверяем, что пользователь не оставлял отзыв на этот ресторан ранее
        let existingReviews = try await repository.fetchUserReviews(userId: userId)
        let hasAlreadyReviewed = existingReviews.contains { $0.restaurantId == restaurantId }
        
        guard !hasAlreadyReviewed else {
            throw UseCaseError.businessLogicError("Вы уже оставляли отзыв на этот ресторан")
        }
        
        // Создаем отзыв
        let review = Review(
            restaurantId: restaurantId,
            userId: userId,
            userName: "Пользователь", // Будет получено из профиля
            rating: rating,
            text: text
        )
        
        do {
            let createdReview = try await repository.createReview(review)
            
            // В реальном приложении здесь можно добавить:
            // - Обновление среднего рейтинга ресторана
            // - Отправку уведомления ресторану
            // - Обновление статистики
            
            return createdReview
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getRestaurantReviews(restaurantId: String) async throws -> [Review] {
        do {
            let reviews = try await repository.fetchRestaurantReviews(restaurantId: restaurantId)
            
            // Сортируем по дате (новые сначала)
            return reviews.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getUserReviews(userId: String) async throws -> [Review] {
        do {
            let reviews = try await repository.fetchUserReviews(userId: userId)
            
            // Сортируем по дате (новые сначала)
            return reviews.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func updateReview(_ review: Review) async throws -> Review {
        // Проверяем, что отзыв можно редактировать
        let timeSinceCreation = Date().timeIntervalSince(review.createdAt)
        let maxEditTime: TimeInterval = 24 * 3600 // 24 часа
        
        guard timeSinceCreation <= maxEditTime else {
            throw UseCaseError.businessLogicError("Отзыв можно редактировать только в течение 24 часов")
        }
        
        do {
            let updatedReview = try await repository.updateReview(review)
            
            // В реальном приложении здесь можно добавить:
            // - Обновление среднего рейтинга ресторана
            // - Логирование изменений
            
            return updatedReview
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func deleteReview(id: String) async throws {
        do {
            try await repository.deleteReview(id: id)
            
            // В реальном приложении здесь можно добавить:
            // - Обновление среднего рейтинга ресторана
            // - Логирование удаления
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    // MARK: - Additional Review Methods
    
    func getReviewStatistics(restaurantId: String) async throws -> ReviewStatistics {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        guard !reviews.isEmpty else {
            return ReviewStatistics(
                averageRating: 0,
                totalReviews: 0,
                ratingDistribution: [:],
                recentReviews: []
            )
        }
        
        // Вычисляем средний рейтинг
        let totalRating = reviews.reduce(0) { $0 + $1.rating }
        let averageRating = totalRating / Double(reviews.count)
        
        // Создаем распределение по рейтингам
        var ratingDistribution: [Int: Int] = [:]
        for review in reviews {
            let rating = Int(review.rating)
            ratingDistribution[rating, default: 0] += 1
        }
        
        // Получаем последние отзывы
        let recentReviews = Array(reviews.prefix(5))
        
        return ReviewStatistics(
            averageRating: averageRating,
            totalReviews: reviews.count,
            ratingDistribution: ratingDistribution,
            recentReviews: recentReviews
        )
    }
    
    func getTopReviews(restaurantId: String, limit: Int = 10) async throws -> [Review] {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        // Сортируем по рейтингу и количеству лайков
        let sortedReviews = reviews.sorted { first, second in
            if first.rating == second.rating {
                return first.helpfulCount > second.helpfulCount
            }
            return first.rating > second.rating
        }
        
        return Array(sortedReviews.prefix(limit))
    }
    
    func getReviewsByRating(restaurantId: String, rating: Double) async throws -> [Review] {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        // Фильтруем по рейтингу
        return reviews.filter { abs($0.rating - rating) < 0.1 }
    }
    
    func getRecentReviews(restaurantId: String, days: Int = 30) async throws -> [Review] {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        // Фильтруем по дате
        return reviews.filter { $0.createdAt >= cutoffDate }
    }
    
    func canEditReview(_ review: Review) -> Bool {
        let timeSinceCreation = Date().timeIntervalSince(review.createdAt)
        let maxEditTime: TimeInterval = 24 * 3600 // 24 часа
        
        return timeSinceCreation <= maxEditTime
    }
    
    func canDeleteReview(_ review: Review) -> Bool {
        let timeSinceCreation = Date().timeIntervalSince(review.createdAt)
        let maxDeleteTime: TimeInterval = 7 * 24 * 3600 // 7 дней
        
        return timeSinceCreation <= maxDeleteTime
    }
    
    // MARK: - Review Moderation
    
    func reportReview(_ review: Review, reason: String) async throws {
        // В реальном приложении здесь была бы логика модерации
        // Пока что просто логируем
        print("🚨 Review reported: \(review.id), reason: \(reason)")
    }
    
    func moderateReview(_ review: Review, action: ReviewModerationAction) async throws {
        switch action {
        case .approve:
            // Отзыв уже одобрен
            break
        case .reject:
            try await deleteReview(id: review.id)
        case .flag:
            // Помечаем отзыв для проверки модератором
            print("🚩 Review flagged for moderation: \(review.id)")
        }
    }
    
    // MARK: - Review Analytics
    
    func getReviewTrends(restaurantId: String, days: Int) async throws -> [Date: Double] {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        let calendar = Calendar.current
        let now = Date()
        
        var trends: [Date: Double] = [:]
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayReviews = reviews.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                let averageRating = dayReviews.isEmpty ? 0 : dayReviews.reduce(0) { $0 + $1.rating } / Double(dayReviews.count)
                trends[date] = averageRating
            }
        }
        
        return trends
    }
    
    func getReviewTrends(restaurantId: String, period: ReviewPeriod) async throws -> ReviewTrends {
        let reviews = try await getRestaurantReviews(restaurantId: restaurantId)
        
        let calendar = Calendar.current
        let now = Date()
        
        var trends: [Date: Double] = [:]
        
        switch period {
        case .week:
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let dayReviews = reviews.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                    let averageRating = dayReviews.isEmpty ? 0 : dayReviews.reduce(0) { $0 + $1.rating } / Double(dayReviews.count)
                    trends[date] = averageRating
                }
            }
        case .month:
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let dayReviews = reviews.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                    let averageRating = dayReviews.isEmpty ? 0 : dayReviews.reduce(0) { $0 + $1.rating } / Double(dayReviews.count)
                    trends[date] = averageRating
                }
            }
        case .year:
            for i in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                    let monthReviews = reviews.filter { calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month) }
                    let averageRating = monthReviews.isEmpty ? 0 : monthReviews.reduce(0) { $0 + $1.rating } / Double(monthReviews.count)
                    trends[date] = averageRating
                }
            }
        }
        
        return ReviewTrends(restaurantId: restaurantId, period: period, trends: trends)
    }
}

// MARK: - Supporting Types

enum ReviewModerationAction {
    case approve
    case reject
    case flag
}

enum ReviewPeriod {
    case week
    case month
    case year
}

struct ReviewTrends {
    let restaurantId: String
    let period: ReviewPeriod
    let trends: [Date: Double]
}
