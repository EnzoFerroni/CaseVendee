//
//  MovieListViewModel.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// View model of the movie list screen (MVVM).
///
/// Owns the data and the search/filter logic; the view controller only
/// renders ``movies`` and forwards user events. The binding is done
/// with two closures — the simplest mechanism that keeps the view
/// passive without any third-party framework.
///
/// `@MainActor` guarantees every property change and callback happens
/// on the main thread, which is mandatory for UI updates.
@MainActor
final class MovieListViewModel {
    /// Called whenever ``movies`` changes, so the view can reload.
    var onMoviesUpdated: (() -> Void)?

    /// Called with a user-friendly message when a request fails.
    var onError: ((String) -> Void)?

    /// Year used to filter both the popular list and the search.
    /// `nil` means "all years".
    var selectedYear: Int?

    /// Movies currently displayed. `private(set)` lets the view read
    /// the list but only the view model change it.
    private(set) var movies: [Movie] = []

    /// Service that performs the TMDb requests.
    private let service = MovieService()

    /// Loads the popular movies shown when there is no search,
    /// respecting ``selectedYear``.
    ///
    /// The work runs inside a `Task` so this method can be called
    /// from synchronous UIKit code (e.g. `viewDidLoad`).
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

    /// Searches by text using ``selectedYear`` as an extra filter.
    ///
    /// An empty query falls back to the popular movies list, which is
    /// what happens when the user clears or cancels the search.
    ///
    /// - Parameter query: Text typed in the search bar.
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
}
