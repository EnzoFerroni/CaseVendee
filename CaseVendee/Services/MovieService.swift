//
//  MovieService.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Possible errors when making a request to the TMDb API.
enum MovieServiceError: Error {
    case invalidURL
    case requestFailed
}

// What the view model needs from a movie service.
// Lets tests replace the real service with a fake one.
protocol MovieFetching {
    func fetchPopularMovies(year: Int?) async throws -> [Movie]
    func searchMovies(query: String, year: Int?) async throws -> [Movie]
}

// Handles all communication with the TMDb API.
// Every request goes through fetchMovies, which builds the URL,
// sends the request and decodes the response.
struct MovieService: MovieFetching {

    private let accessToken = Secrets.tmdbAccessToken
    private let baseURL = "https://api.themoviedb.org/3"

    // Fetches the most popular movies, with an optional year filter.
    func fetchPopularMovies(year: Int?) async throws -> [Movie] {
        var queryItems = [URLQueryItem(name: "sort_by", value: "popularity.desc")]

        if let year {
            queryItems.append(
                URLQueryItem(name: "primary_release_year", value: String(year))
            )
        }

        return try await fetchMovies(path: "/discover/movie", queryItems: queryItems)
    }

    // Searches movies by text, with an optional year filter.
    func searchMovies(query: String, year: Int?) async throws -> [Movie] {
        var queryItems = [URLQueryItem(name: "query", value: query)]

        if let year {
            queryItems.append(
                URLQueryItem(name: "primary_release_year", value: String(year))
            )
        }

        return try await fetchMovies(path: "/search/movie", queryItems: queryItems)
    }

    // Builds the URL, sends the request and decodes the movie list.
    // Language is added here so every request returns results in Portuguese.
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

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MovieResponse.self, from: data).results
    }
}
