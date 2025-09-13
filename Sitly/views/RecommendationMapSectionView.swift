//
//  RecommendationMapSectionView.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 08.07.2025.
//

import SwiftUI
import MapKit

struct RecommendationMapSectionView: View {
   
    let recommendedRestaurant: Restaurant
    @Binding var region: MKCoordinateRegion
    
    
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Cоветуем в этом районе")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack{
                Map(coordinateRegion: $region, annotationItems: [recommendedRestaurant]) { restaurant in
                    MapMarker(coordinate: restaurant.coordinates, tint: .red)
                }
                .frame(width: 140, height: 100)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing:8){
                    Text(recommendedRestaurant.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(recommendedRestaurant.address)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Button(action: {
                        //
                    }){
                        Image(systemName: "location.fill")
                    }
                }
                .padding(.leading, 35)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
}
