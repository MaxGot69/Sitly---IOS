import SwiftUI
import CoreLocation

struct ModernCard<Content: View>: View {
    let content: Content
    let style: ModernCardVariant
    
    init(style: ModernCardVariant = .default, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(style.padding)
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: style.shadowOffset.x,
                y: style.shadowOffset.y
            )
    }
}

// MARK: - Card Styles

enum ModernCardVariant {
    case `default`
    case elevated
    case outlined
    case glass
    
    var background: some View {
        switch self {
        case .default:
            Color(red: 0.1, green: 0.1, blue: 0.12)
        case .elevated:
            Color(red: 0.12, green: 0.12, blue: 0.15)
        case .outlined:
            Color.clear
        case .glass:
            Color.clear
        }
    }
    
    var borderColor: Color {
        switch self {
        case .default, .elevated, .glass:
            return .clear
        case .outlined:
            return .white.opacity(0.2)
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outlined:
            return 1
        default:
            return 0
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .default, .elevated:
            return 16
        case .outlined, .glass:
            return 12
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .default, .elevated:
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        case .outlined, .glass:
            return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .default:
            return .black.opacity(0.1)
        case .elevated:
            return .black.opacity(0.2)
        case .outlined, .glass:
            return .clear
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .default:
            return 8
        case .elevated:
            return 16
        case .outlined, .glass:
            return 0
        }
    }
    
    var shadowOffset: CGPoint {
        switch self {
        case .default:
            return CGPoint(x: 0, y: 4)
        case .elevated:
            return CGPoint(x: 0, y: 8)
        case .outlined, .glass:
            return CGPoint(x: 0, y: 0)
        }
    }
}

// MARK: - Restaurant Card

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    
    var body: some View {
        ModernCard(style: .elevated) {
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    )
                
                // Restaurant info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(restaurant.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Rating badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                    }
                    
                    Text(restaurant.cuisineType.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.mint)
                    
                    // Details row
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text("2.3 км")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text("25 мин")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("PPP")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                // Status button
                HStack {
                    Spacer()
                    
                    ModernButton(
                        title: "Открыто",
                        style: .primary
                    ) {
                        onTap()
                    }
                    .frame(width: 80)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        RestaurantCard(
            restaurant: Restaurant(
                id: "preview_1",
                name: "Pushkin",
                description: "Культовое заведение",
                cuisineType: .russian,
                address: "Тверской бул., 26А",
                coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                phoneNumber: "+7 (495) 123-45-67",
                website: "https://pushkin.ru",
                rating: 4.6,
                reviewCount: 1250,
                priceRange: .high,
                workingHours: WorkingHours(),
                photos: ["pushkin"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner1",
                subscriptionPlan: .premium,
                status: .active,
                features: [.wifi, .parking, .outdoorSeating],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            )
        ) {
            print("Restaurant tapped")
        }
        
        ModernCard(style: .glass) {
            Text("Glass Card")
                .foregroundColor(.white)
        }
        
        ModernCard(style: .outlined) {
            Text("Outlined Card")
                .foregroundColor(.white)
        }
    }
    .padding()
    .background(Color.black)
} 