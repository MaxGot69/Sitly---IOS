//
//  RestaurantListViewModel.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 30.06.2025.
//

import Foundation
import MapKit

final class RestaurantListViewModel: ObservableObject{
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), // Москва
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var restaurants : [Restaurant] = [
        Restaurant(
            name: "Pushkin",
            cuisine: "Русская",
            address: "Тверской бул., 26А, Москва",
            rating: 4.6,
            imageName: "Pushkin",
            coordinate: .init(latitude: 55.7652, longitude: 37.6041)
        ),
        
        Restaurant(name: "Тверь",
                   cuisine: "Европейская",
                   address:"Тверской бул., 26А, Москва",
                   rating: 4.6,
                   imageName: "Тверь",
                   coordinate: .init(latitude: 55.7652, longitude: 37.6041)),
        
        Restaurant(name: "Dr. Живаго",
                   cuisine: "Европейская",
                   address: "Охотный ряд, 15, Москва",
                   rating: 5.0,
                   imageName:  "Dr. Живаго",
                   coordinate: .init(latitude: 55.7563, longitude: 37.6159)),
        
        Restaurant(name: "СибирьСибирь",
                   cuisine: "Европейская",
                   address: "Садовая-Самотечная, 20, Москва",
                   rating: 4.3,
                   imageName:  "СибирьСибирь",
                   coordinate: .init(latitude: 55.7756, longitude: 37.6216)),
        Restaurant(name: "Сыроварня",
                   cuisine: "Итальянская",
                   address: "Болотная наб., 11, стр. 1, Москва",
                   rating: 4.8,
                   imageName: "Сыроварня",
                   coordinate: .init(latitude: 55.7411, longitude: 37.6281))
    ]
    
    @Published var searchText: String = ""
    @Published var selectedFilter:String = ""
    
    //Фильтрация поиск и чипы
    var filteredRestaurants: [Restaurant]{
        var result = restaurants
        if !searchText.isEmpty{
            result = result.filter{ $0.name.lowercased().contains(searchText.lowercased())}
        }
        if !selectedFilter.isEmpty{
            result = result.filter {$0.cuisine == selectedFilter}
        }
        return result
    }
}
