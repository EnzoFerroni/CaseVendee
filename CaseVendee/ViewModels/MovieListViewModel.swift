//
//  MovieListViewModel.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// View model of the movie list screen (MVVM). It owns the data and
/// the search/filter logic; the view controller only renders it.
@MainActor
final class MovieListViewModel {
    /// Called whenever `movies` changes, so the view can reload.
    var onMoviesUpdated: (() -> Void)?

    /// Called with a user-friendly message when a request fails.
    var onError: ((String) -> Void)?

    private(set) var movies: [Movie] = []
    private(set) var selectedYear: Int?

    private let service = MovieService()

    /// Loads the popular movies shown when there is no search,
    /// respecting the selected year filter.
    func loadPopularMovies() {
        Task {
            do {
                movies = try await service.fetchPopularMovies(year: selectedYear)
                onMoviesUpdated?()
            }
            catch {
                onError?("Could not load movies. Check your connection.")
            }
        }
    }

    /// Searches by text using the selected year as an extra filter.
    /// An empty query falls back to the popular movies list.
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            loadPopularMovies()
            return
        }

        Task {
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
        }
    }

    /// Stores the year filter; `nil` means all years.
    func selectYear(_ year: Int?) {
        selectedYear = year
    }
}
