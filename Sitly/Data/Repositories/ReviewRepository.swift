import Foundation

final class ReviewRepository: ReviewRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
    }
    
    // MARK: - Review Management
    
    func createReview(_ review: Review) async throws -> Review {
        // В реальном приложении здесь был бы API вызов
        // Пока что сохраняем локально
        
        // Генерируем уникальный ID для отзыва
        let newReview = Review(
            id: UUID().uuidString,
            restaurantId: review.restaurantId,
            userId: review.userId,
            userName: review.userName,
            rating: review.rating,
            text: review.text,
            createdAt: review.createdAt,
            photos: review.photos,
            helpfulCount: review.helpfulCount,
            isVerified: review.isVerified
        )
        
        // Сохраняем в локальное хранилище
        try await storageService.save(newReview, forKey: "review_\(newReview.id)")
        
        // Добавляем в список отзывов ресторана
        var restaurantReviews = try await fetchRestaurantReviews(restaurantId: review.restaurantId)
        restaurantReviews.append(newReview)
        try await storageService.save(restaurantReviews, forKey: "restaurant_reviews_\(review.restaurantId)")
        
        // Добавляем в список отзывов пользователя
        var userReviews = try await fetchUserReviews(userId: review.userId)
        userReviews.append(newReview)
        try await storageService.save(userReviews, forKey: "user_reviews_\(review.userId)")
        
        return newReview
    }
    
    func fetchRestaurantReviews(restaurantId: String) async throws -> [Review] {
        // Получаем из локального хранилища
        if let reviews: [Review] = try? await storageService.load([Review].self, forKey: "restaurant_reviews_\(restaurantId)") {
            return reviews
        }
        
        // Если нет сохраненных отзывов, возвращаем пустой массив
        return []
    }
    
    func fetchUserReviews(userId: String) async throws -> [Review] {
        // Получаем из локального хранилища
        if let reviews: [Review] = try? await storageService.load([Review].self, forKey: "user_reviews_\(userId)") {
            return reviews
        }
        
        // Если нет сохраненных отзывов, возвращаем пустой массив
        return []
    }
    
    func updateReview(_ review: Review) async throws -> Review {
        // Получаем все отзывы ресторана
        var restaurantReviews = try await fetchRestaurantReviews(restaurantId: review.restaurantId)
        
        guard let reviewIndex = restaurantReviews.firstIndex(where: { $0.id == review.id }) else {
            throw RepositoryError.notFound
        }
        
        // Обновляем отзыв
        restaurantReviews[reviewIndex] = review
        
        // Обновляем в локальном хранилище
        try await storageService.save(restaurantReviews, forKey: "restaurant_reviews_\(review.restaurantId)")
        
        // Обновляем в списке пользователя
        try await updateReviewInUserList(review)
        
        return review
    }
    
    func deleteReview(id: String) async throws {
        // Получаем все отзывы из хранилища
        // Временно используем пустой массив, так как getKeys не реализован
        let keys: [String] = []
        var reviewToDelete: Review?
        
        for key in keys {
            if key.hasPrefix("review_") {
                if let review: Review = try? await storageService.load(Review.self, forKey: key) {
                    if review.id == id {
                        reviewToDelete = review
                        break
                    }
                }
            }
        }
        
        guard let review = reviewToDelete else {
            throw RepositoryError.notFound
        }
        
        // Удаляем из списка ресторана
        var restaurantReviews = try await fetchRestaurantReviews(restaurantId: review.restaurantId)
        restaurantReviews.removeAll { $0.id == id }
        try await storageService.save(restaurantReviews, forKey: "restaurant_reviews_\(review.restaurantId)")
        
        // Удаляем из списка пользователя
        try await removeReviewFromUserList(review)
        
        // Удаляем сам отзыв
        try await storageService.delete(forKey: "review_\(id)")
    }
    
    // MARK: - Private Methods
    
    private func updateReviewInUserList(_ review: Review) async throws {
        var userReviews = try await fetchUserReviews(userId: review.userId)
        
        if let index = userReviews.firstIndex(where: { $0.id == review.id }) {
            userReviews[index] = review
            try await storageService.save(userReviews, forKey: "user_reviews_\(review.userId)")
        }
    }
    
    private func removeReviewFromUserList(_ review: Review) async throws {
        var userReviews = try await fetchUserReviews(userId: review.userId)
        
        userReviews.removeAll { $0.id == review.id }
        try await storageService.save(userReviews, forKey: "user_reviews_\(review.userId)")
    }
}
