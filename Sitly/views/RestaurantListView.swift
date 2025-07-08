import SwiftUI
import MapKit

struct RestaurantListView: View {
    @StateObject private var viewModel = RestaurantListViewModel()

    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading, spacing: 16){
                //Searchbar
                TextField("Введите название или кухню", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 12){
                        FilterButton(title: "🔥 Популярные")
                        FilterButton(title: "🥦 Вегетарианские")
                        FilterButton(title: "💰 Бюджетные")
                        FilterButton(title: "🍷 Романтика")
                    }
                    .padding(.horizontal)
                }
                if let recommended = viewModel.restaurants.first{
                    RecommendationMapSectionView(
                        recommendedRestaurant: recommended,
                        region: $viewModel.region
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                NavigationView{
                    List(viewModel.filteredRestaurants){restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)){
                            RestaurantCardView(restaurant: restaurant)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Рестораны")

                //FilterChips
                
                //Kart
                
                
                }
                
            }
            .padding(.top)
        }
        
    }

