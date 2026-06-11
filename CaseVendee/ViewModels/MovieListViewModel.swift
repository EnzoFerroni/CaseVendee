//
//  MovieListViewModel.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Holds all data and logic for the movie list screen.
// The view controller only reads movies and forwards user actions to this class.
// @MainActor ensures all updates happen on the main thread, which UIKit requires.
@MainActor
final class MovieListViewModel {

    // Called when the movie list changes so the table can reload.
    var onMoviesUpdated: (() -> Void)?

    // Called with an error message when a request fails.
    var onError: ((String) -> Void)?

    // Called when a request starts or ends so the view can show a spinner.
    var onLoadingChanged: ((Bool) -> Void)?

    // Year selected in the filter menu. nil means no filter.
    var selectedYear: Int?

    // The movies shown on screen. Only this class can change the list.
    private(set) var movies: [Movie] = []

    private let service: MovieFetching

    // The service can be injected so tests can pass a fake one.
    init(service: MovieFetching? = nil) {
        self.service = service ?? MovieService()
    }

    // Loads the most popular movies. Used on launch and after cancelling a search.
    func loadPopularMovies() {
        Task {
            onLoadingChanged?(true)

            do {
                movies = try await service.fetchPopularMovies(year: selectedYear)
                onMoviesUpdated?()
            }
            catch {
                onError?("Could not load movies. Check your connection.")
            }

            onLoadingChanged?(false)
        }
    }

    // Searches movies by text. Falls back to the popular list if the query is empty.
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            loadPopularMovies()
            return
        }

        Task {
            onLoadingChanged?(true)

            do {
                movies = try await service.searchMovies(
                    query: query,
                    year: selectedYear
                )
                onMoviesUpdated?()
            }
            catch {
                onError?("Search failed. Try again.")
            }

            onLoadingChanged?(false)
        }
    }
}
