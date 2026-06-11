//
//  MovieTests.swift
//  CaseVendeeTests
//
//  Created by Enzo Ferroni on 11/06/26.
//

import XCTest
@testable import CaseVendee

// Tests for the Movie computed properties and the TMDb JSON decoding.
final class MovieTests: XCTestCase {

    func testPosterURLIsBuiltFromPosterPath() {
        let movie = makeMovie(posterPath: "/poster.jpg")

        XCTAssertEqual(
            movie.posterURL?.absoluteString,
            "https://image.tmdb.org/t/p/w500/poster.jpg"
        )
    }

    func testPosterURLIsNilWithoutPosterPath() {
        let movie = makeMovie(posterPath: nil)

        XCTAssertNil(movie.posterURL)
    }

    func testReleaseYearUsesFirstFourCharacters() {
        let movie = makeMovie(releaseDate: "2024-05-10")

        XCTAssertEqual(movie.releaseYear, "2024")
    }

    func testReleaseYearShowsDashWithoutDate() {
        let movie = makeMovie(releaseDate: nil)

        XCTAssertEqual(movie.releaseYear, "-")
    }

    func testSummaryTextCombinesYearAndRating() {
        let movie = makeMovie(releaseDate: "2024-05-10", voteAverage: 8.5)

        XCTAssertEqual(movie.summaryText, "2024 | ★8.5")
    }

    // Decodes a sample of the real TMDb JSON to check the key mapping.
    func testDecodingFromTMDbJSON() throws {
        let json = Data("""
        {
            "results": [{
                "id": 603,
                "title": "Matrix",
                "overview": "A hacker discovers the truth.",
                "poster_path": "/matrix.jpg",
                "release_date": "1999-03-31",
                "vote_average": 8.2
            }]
        }
        """.utf8)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let movies = try decoder.decode(MovieResponse.self, from: json).results

        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.title, "Matrix")
        XCTAssertEqual(movies.first?.releaseYear, "1999")
    }

    // Builds a movie changing only the values each test cares about.
    private func makeMovie(
        posterPath: String? = "/poster.jpg",
        releaseDate: String? = "2024-05-10",
        voteAverage: Double = 8.5
    ) -> Movie {
        Movie(
            id: 1,
            title: "Test Movie",
            overview: "Overview",
            posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage
        )
    }
}
