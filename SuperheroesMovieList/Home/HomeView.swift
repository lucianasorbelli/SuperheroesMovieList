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
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard)
        }
        .background(.black)
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if let movie = viewModel.selectedMovie {
                MovieDetailSheetView(movie: movie)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(movie.title), año \(movie.year)")
                    .accessibilityHint("Toca dos veces para ver los detalles de la película")
            }
        }
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 8) {
            sortButtonView
            resetButton
        }
        .disabled(viewModel.isLoadingMore)
    }
    
    private var sortButtonView: some View {
        Button(action: {
            viewModel.sortByYear()
        }, label: {
            Text(viewModel.defaultSortCriteria.displayName)
                .padding(20)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background( viewModel.isLoadingMore ? .gray : .blue)
                .cornerRadius(14)
        })
        .accessibilityLabel("Ordenar películas por \(viewModel.defaultSortCriteria.displayName)")
        .accessibilityHint("Toca dos veces para cambiar el orden de las películas")
    }
    
    private var resetButton: some View {
        Button(action: {
            viewModel.loadFullMovies()
        }, label: {
            Text("Reset")
                .padding(20)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background( viewModel.isLoadingMore ? .gray : .blue)
                .cornerRadius(14)
        })
        .accessibilityLabel("Restablecer lista de películas")
        .accessibilityHint("Vuelve a mostrar todas las películas")
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
                        .onAppear(perform: {
                            if let lastMovie = viewModel.moviesFiltered.last {
                                viewModel.loadMoreMovies()
                            }
                        })
                        .onTapGesture {
                            viewModel.didTap(movie)
                        }
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
            Group{
                Text("Something went wrong")
                Text("Please try again")
            }
            .font(.title3)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
            .padding(.top, 30)
            .padding(.horizontal, 20)
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
            Text("No se han encontrado películas, por favor intente con otro título")
                .multilineTextAlignment(.center)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 30)
                .padding(.horizontal, 20)
                .foregroundStyle(.white)
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
                    .foregroundColor(.white)
                
                TextField("Search Movies...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .foregroundStyle(.white)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.none)
                    .accessibilityLabel("Buscar películas")
                    .accessibilityHint("Ingrese el nombre de la película")
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.searchText) { newValue in
                        Task {
                            viewModel.searchMovies()
                        }
                    }
                if !viewModel.searchText.isEmpty {
                    searchCloseButton
                }
            }
            .padding()
            .cornerRadius(20)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.vertical, 12)
        .background(.black)
        .cornerRadius(10)
    }
    
    private var searchCloseButton: some View {
        Button(action: {
            viewModel.closeTextField()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }.accessibilityLabel("Borrar búsqueda")
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
