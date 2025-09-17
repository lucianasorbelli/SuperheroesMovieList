//
//  HomeView.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import SwiftUI

struct HomeView<ViewModel>: View where ViewModel: HomeViewModeling {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBarView
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .error:
                    errorView
                case .content:
                    contentMoviesView
                case .empty:
                    errorView
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var contentMoviesView: some View {
        List {
            ForEach(viewModel.moviesFiltered) { movie in
                MovieRowView(movie: movie)
                    .listRowBackground(Color(.systemGray6))
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.systemBackground))
    }
    
    private var errorView: some View {
        VStack(alignment: .center) {
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.heavy)
            Text("Please try again")
                .font(.title3)
                .fontWeight(.light)
            Button(action: {
                viewModel.executeCurrentService()
            }, label: {
                Text("Reintentar")
            })
        }
    }
    
    private var loadingView: some View {
        ProgressView("Cargando películas...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchBarView: some View {
        VStack(spacing: 16) {
            Text("Movie List")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search Movies...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.none)
                    .onChange(of: viewModel.searchText) { newValue in
                        Task {
                            await viewModel.searchMovies()
                        }
                    }
                if !viewModel.searchText.isEmpty {
                    searchCloseButton
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var searchCloseButton: some View {
        Button(action: {
            viewModel.closeTextField()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
