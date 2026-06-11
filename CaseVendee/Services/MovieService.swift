//
//  MovieService.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

/// Errors that ``MovieService`` can throw.
enum MovieServiceError: Error {
    /// The URL could not be built from its components.
    case invalidURL

    /// The server did not answer with HTTP 200.
    case requestFailed
}

/// Talks to the TMDb API and decodes responses into ``Movie`` values.
///
/// Every request shares the same flow, implemented once in
/// ``fetchMovies(path:queryItems:)``: build the URL, attach the
/// authentication header, perform the call with async/await and decode
/// the JSON. The public methods only choose the endpoint and the
/// parameters specific to it.
struct MovieService {
    /// TMDb v4 read access token, sent as a Bearer token on every
    /// request. It lives in `Secrets.swift`, a file kept out of
    /// version control so the key is never exposed in the repository.
    private let accessToken = Secrets.tmdbAccessToken

    /// Common prefix of every TMDb v3 endpoint.
    private let baseURL = "https://api.themoviedb.org/3"

    /// Fetches movies sorted by popularity, optionally filtered by year.
    ///
    /// Uses `/discover/movie` instead of `/movie/popular` because the
    /// discover endpoint accepts filters; with `sort_by=popularity.desc`
    /// it returns the same ranking as the popular endpoint.
    ///
    /// - Parameter year: Release year to filter by; `nil` means all years.
    /// - Returns: The first page of movies, ordered by popularity.
    /// - Throws: ``MovieServiceError`` or any networking/decoding error.
    func fetchPopularMovies(year: Int?) async throws -> [Movie] {
        var queryItems = [URLQueryItem(name: "sort_by", value: "popularity.desc")]

        if let year {
            queryItems.append(
                URLQueryItem(name: "primary_release_year", value: String(year))
            )
        }

        return try await fetchMovies(path: "/discover/movie", queryItems: queryItems)
    }

    /// Searches movies by text, optionally filtered by release year.
    ///
    /// - Parameters:
    ///   - query: Text typed by the user in the search bar.
    ///   - year: Release year to filter by; `nil` means all years.
    /// - Returns: Movies matching the query, ranked by TMDb relevance.
    /// - Throws: ``MovieServiceError`` or any networking/decoding error.
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
    ///
    /// - Parameters:
    ///   - path: Endpoint path appended to ``baseURL`` (e.g. `/search/movie`).
    ///   - queryItems: Endpoint-specific parameters. The language is
    ///     added here so every request is localized the same way.
    /// - Returns: The decoded movies of the response.
    /// - Throws: ``MovieServiceError/invalidURL`` when the URL cannot be
    ///   built, ``MovieServiceError/requestFailed`` on a non-200 answer,
    ///   or a `DecodingError` when the JSON does not match the model.
    private func fetchMovies(
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> [Movie] {
        // 1. Build the URL from the base, the path and the parameters.
        guard var components = URLComponents(string: baseURL + path) else {
            throw MovieServiceError.invalidURL
        }

        components.queryItems =
            [URLQueryItem(name: "language", value: "pt-BR")] + queryItems

        guard let url = components.url else {
            throw MovieServiceError.invalidURL
        }

        // 2. Authenticate with the Bearer token header, as recommended
        //    by the TMDb documentation for v4 tokens.
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(accessToken)", forHTTPHeaderField: "Authorization"
        )

        // 3. Perform the request and make sure the server answered 200.
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MovieServiceError.requestFailed
        }

        // 4. Decode the snake_case JSON into the camelCase model.
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MovieResponse.self, from: data).results
    }
}
