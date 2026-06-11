//
//  MovieDetailView.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

/// Detail screen written in SwiftUI and pushed from UIKit through a
/// `UIHostingController`, showing the gradual migration to SwiftUI.
struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(height: 400)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(movie.title)
                    .font(.title)
                    .bold()

                HStack(spacing: 16) {
                    Label(movie.releaseYear, systemImage: "calendar")

                    Label(
                        String(format: "%.1f", movie.voteAverage),
                        systemImage: "star.fill"
                    )
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(movie.overview.isEmpty ? "No overview available." : movie.overview)
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MovieDetailView(
        movie: Movie(
            id: 1,
            title: "Sample Movie",
            overview: "A short overview used for previewing this screen.",
            posterPath: nil,
            releaseDate: "2026-01-01",
            voteAverage: 8.2
        )
    )
}
