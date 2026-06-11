//
//  Movie.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Represents a movie returned by the TMDb API.
// The decoder is set to convert snake_case keys to camelCase automatically.
struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String

    // nil when the movie has no poster registered on TMDb.
    let posterPath: String?

    // nil when the movie has no release date registered on TMDb.
    let releaseDate: String?

    let voteAverage: Double

    // Builds the full poster image URL from the relative path.
    var posterURL: URL? {
        guard let posterPath else {
            return nil
        }

        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    // Extracts the year from the release date string.
    // Returns a dash if the date is missing.
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else {
            return "-"
        }

        return String(releaseDate.prefix(4))
    }

    // Short summary line shown on the list and detail screens.
    var summaryText: String {
        "\(releaseYear) | ★" + String(format: "%.1f", voteAverage)
    }
}

// Wrapper for the TMDb response, which returns movies inside a results array.
struct MovieResponse: Decodable {
    let results: [Movie]
}
