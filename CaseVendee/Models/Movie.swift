//
//  Movie.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// A movie as returned by the TMDb API.
///
/// The JSON uses snake_case keys (`poster_path`, `release_date`,
/// `vote_average`). The decoder in ``MovieService`` is configured with
/// the `convertFromSnakeCase` strategy, so each key maps automatically
/// to the camelCase property of the same name.
struct Movie: Decodable {
    /// Unique TMDb identifier of the movie.
    let id: Int

    /// Title localized to the language requested by the service
    /// (pt-BR). TMDb falls back to the original title when there is
    /// no translation.
    let title: String

    /// Synopsis of the movie. May be an empty string when TMDb has
    /// no translated overview for it.
    let overview: String

    /// Relative path of the poster image (e.g. `/abc123.jpg`).
    /// Optional because some movies have no registered poster.
    let posterPath: String?

    /// Release date in `yyyy-MM-dd` format. Optional because some
    /// TMDb entries have no date at all.
    let releaseDate: String?

    /// Average user rating, from 0 to 10.
    let voteAverage: Double

    /// Full URL of the poster image, when the movie has one.
    ///
    /// TMDb serves images from a separate CDN, so the relative
    /// ``posterPath`` is appended to the image base URL. The `w500`
    /// segment requests a 500px-wide version — enough quality for
    /// both the list and the detail screen.
    var posterURL: URL? {
        guard let posterPath else {
            return nil
        }

        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    /// Release year extracted from ``releaseDate`` (e.g. "2022").
    ///
    /// Returns "-" when the date is missing or malformed, so the UI
    /// always has something to display.
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else {
            return "-"
        }

        return String(releaseDate.prefix(4))
    }

    /// Short "year · rating" line shown in the list and detail screens.
    ///
    /// Centralized here so both screens format the information exactly
    /// the same way (rating always with one decimal place).
    var summaryText: String {
        "\(releaseYear)  ·  ★ " + String(format: "%.1f", voteAverage)
    }
}

/// Top-level object returned by the TMDb list endpoints.
///
/// Both `/discover/movie` and `/search/movie` wrap the movies in a
/// `results` array. Pagination fields (`page`, `total_pages`) are
/// ignored on purpose — the app only shows the first page.
struct MovieResponse: Decodable {
    /// Movies of the current page (TMDb returns up to 20 per page).
    let results: [Movie]
}
