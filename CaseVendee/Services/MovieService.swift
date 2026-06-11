//
//  MovieService.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// Errors that `MovieService` can throw.
enum MovieServiceError: Error {
    case invalidURL
    case requestFailed
}

/// Talks to the TMDb API and decodes responses into `Movie` values.
struct MovieService {
    /// TMDb v4 read access token, sent as a Bearer token on every request.
    /// Lives in `Secrets.swift`, which is kept out of version control.
    private let accessToken = Secrets.tmdbAccessToken
    private let baseURL = "https://api.themoviedb.org/3"

    /// Fetches the most popular movies (initial content of the main screen).
    func fetchPopularMovies() async throws -> [Movie] {
        try await fetchMovies(path: "/movie/popular", queryItems: [])
    }

    /// Searches movies by text, optionally filtered by release year.
    func searchMovies(query: String, year: Int?) async throws -> [Movie] {
        var queryItems = [URLQueryItem(name: "query", value: query)]

        if let year {
            queryItems.append(
                URLQueryItem(name: "primary_release_year", value: String(year))
            )
        }

        return try await fetchMovies(path: "/search/movie", queryItems: queryItems)
    }

    /// Builds the URL, performs the request and decodes the movie list.
    private func fetchMovies(
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> [Movie] {
        guard var components = URLComponents(string: baseURL + path) else {
            throw MovieServiceError.invalidURL
        }

        components.queryItems =
            [URLQueryItem(name: "language", value: "pt-BR")] + queryItems

        guard let url = components.url else {
            throw MovieServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(accessToken)", forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MovieServiceError.requestFailed
        }

        // TMDb uses snake_case keys (e.g. poster_path -> posterPath).
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MovieResponse.self, from: data).results
    }
}
