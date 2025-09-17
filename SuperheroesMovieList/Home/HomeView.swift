//
//  HomeView.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import SwiftUI

struct HomeView<ViewModel>: View where ViewModel: HomeViewModeling {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}
