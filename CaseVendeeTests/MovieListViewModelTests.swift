//
//  MovieListViewModelTests.swift
//  CaseVendeeTests
//
//  Created by Enzo Ferroni on 11/06/26.
//

import XCTest
@testable import CaseVendee

// Fake service that returns fixed results without calling the network.
private struct MovieServiceMock: MovieFetching {

    var movies: [Movie] = []
    var shouldFail = false

    func fetchPopularMovies(year: Int?) async throws -> [Movie] {
        try result()
    }

    func searchMovies(query: String, year: Int?) async throws -> [Movie] {
        try result()
    }

    private func result() throws -> [Movie] {
        guard !shouldFail else {
            throw MovieServiceError.requestFailed
        }

        return movies
    }
}

// Tests for the movie list state and the view model callbacks.
final class MovieListViewModelTests: XCTestCase {

    private let movie = Movie(
        id: 1,
        title: "Test Movie",
        overview: "Overview",
        posterPath: nil,
        releaseDate: nil,
        voteAverage: 8.5
    )

    func testLoadPopularMoviesUpdatesList() {
        let viewModel = MovieListViewModel(
            service: MovieServiceMock(movies: [movie])
        )
        let updated = expectation(description: "movies updated")
        viewModel.onMoviesUpdated = {
            updated.fulfill()
        }

        viewModel.loadPopularMovies()

        wait(for: [updated], timeout: 1)
        XCTAssertEqual(viewModel.movies.first?.title, "Test Movie")
    }

    func testLoadPopularMoviesReportsError() {
        let viewModel = MovieListViewModel(
            service: MovieServiceMock(shouldFail: true)
        )
        let failed = expectation(description: "error reported")
        viewModel.onError = { _ in
            failed.fulfill()
        }

        viewModel.loadPopularMovies()

        wait(for: [failed], timeout: 1)
        XCTAssertTrue(viewModel.movies.isEmpty)
    }

    func testSearchMoviesUpdatesList() {
        let viewModel = MovieListViewModel(
            service: MovieServiceMock(movies: [movie])
        )
        let updated = expectation(description: "movies updated")
        viewModel.onMoviesUpdated = {
            updated.fulfill()
        }

        viewModel.searchMovies(query: "Test")

        wait(for: [updated], timeout: 1)
        XCTAssertEqual(viewModel.movies.count, 1)
    }

    // The spinner callback must fire when the request starts and ends.
    func testLoadingCallbackFiresAroundRequest() {
        let viewModel = MovieListViewModel(
            service: MovieServiceMock(movies: [movie])
        )
        let finished = expectation(description: "loading finished")
        var loadingStates: [Bool] = []
        viewModel.onLoadingChanged = { isLoading in
            loadingStates.append(isLoading)
            if !isLoading {
                finished.fulfill()
            }
        }

        viewModel.loadPopularMovies()

        wait(for: [finished], timeout: 1)
        XCTAssertEqual(loadingStates, [true, false])
    }
}
