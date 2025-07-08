//
//  RestaurantCardView.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 08.07.2025.
//

import SwiftUI
import MapKit

struct RestaurantCardView: View {
    let restaurant: Restaurant
    var body: some View {
        HStack(spacing: 20){
            Image(restaurant.imageName)
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius:10))
            VStack(alignment: .leading, spacing:4){
                HStack{
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(String(format: "%.1f", restaurant.rating ))
                        .foregroundColor(.yellow)
                        .bold()
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Text("📍 \(restaurant.cuisine)")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

#Preview {
    RestaurantCardView(restaurant: Restaurant(
        name: "Test",
        cuisine: "Тестовая",
        address: "Москва",
        rating: 4.5,
        imageName: "white_rabbit",
        coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176)
    ))
    .preferredColorScheme(.dark)
}
