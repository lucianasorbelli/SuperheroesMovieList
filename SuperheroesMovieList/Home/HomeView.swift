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
            VStack(spacing: 8) {
                searchBarView
                actionButtonsView
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .error:
                    errorView
                case .content:
                    contentMoviesView
                case .empty:
                    emptyMoviesView
                }
            }
            .background(.black)
            .ignoresSafeArea(.keyboard)
        }
        .background(.black)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 8) {
            sortButtonView
            resetButton
        }
        .disabled(viewModel.isLoadingMore)
    }
    
    private var resetButton: some View {
        Button(action: {
            viewModel.loadFullMovies()
        }, label: {
            Text("Reset")
                .padding(20)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(.gray)
                .cornerRadius(14)
        })
    }
    
    private var sortButtonView: some View {
        Button(action: {
            viewModel.sortByYear()
        }, label: {
            Text(viewModel.defaultSortCriteria.displayName)
                .padding(20)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(.gray)
                .cornerRadius(14)
        })
    }
    
    private var contentMoviesView: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.moviesFiltered) { movie in
                    MovieRowView(movie: movie)
                        .listRowSeparatorTint(.clear)
                        .background(.black)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white, lineWidth: 1)
                        }
                }
            }
            .task(id: viewModel.moviesFiltered.last?.id) {
                if let last = viewModel.moviesFiltered.last {
                    viewModel.loadMoreMovies()
                }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
        .background(.black)
    }
    
    private var errorView: some View {
        VStack(alignment: .center) {
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.top, 30)
            Text("Please try again")
                .font(.title3)
                .fontWeight(.light)
            Button(action: {
                viewModel.executeCurrentService()
            }, label: {
                Text("Reintentar")
            })
            Spacer()
        }
    }
    
    private var emptyMoviesView: some View {
        VStack(alignment: .center) {
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.top, 30)
            Text("Please try again")
                .font(.title3)
                .fontWeight(.light)
            Button(action: {
                viewModel.executeCurrentService()
            }, label: {
                Text("Reintentar")
            })
            Spacer()
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
                    .foregroundStyle(.white)
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
