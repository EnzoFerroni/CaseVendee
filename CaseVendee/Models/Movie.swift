//
//  Movie.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// A movie as returned by the TMDb API.
struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double

    /// Full URL of the poster image, when the movie has one.
    var posterURL: URL? {
        guard let posterPath else {
            return nil
        }

        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    /// Release year extracted from the "yyyy-MM-dd" date string.
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else {
            return "-"
        }

        return String(releaseDate.prefix(4))
    }
}

/// Top-level object returned by the TMDb list endpoints.
struct MovieResponse: Decodable {
    let results: [Movie]
}
