import SwiftUI

struct RestaurantCardView: View {
    let restaurant: Restaurant
    @State private var isTapped = false
    
    var body: some View {
        let imageView = Image(restaurant.photos.first ?? "placeholder")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        
        let infoView = VStack(alignment: .leading, spacing: 6) {
            // Название и рейтинг
            HStack {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", restaurant.rating))
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                }
            }
            
            // Кухня и адрес
            Text(restaurant.cuisineType.displayName)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(restaurant.address)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            // Столики
            if restaurant.tables.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "chair.lounge.fill")
                        .foregroundColor(.mint)
                    Text("\(restaurant.tables.count) столиков свободно")
                        .font(.caption)
                        .foregroundColor(.mint)
                }
            }
        }
        
        return HStack(spacing: 16) {
            imageView
            infoView
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(isTapped ? 0.96 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isTapped)
        .onTapGesture {
            isTapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTapped = false
            }
        }
    }
}
