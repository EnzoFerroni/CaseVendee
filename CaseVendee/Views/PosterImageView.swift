//
//  PosterImageView.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Poster component shared by the list cell and the detail screen.
/// Downloads the image with cache and falls back to a film symbol
/// when the movie has no poster.
final class PosterImageView: UIImageView {
    private var loadTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 8
        backgroundColor = .secondarySystemBackground
        tintColor = .secondaryLabel
        preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
    }

    required init?(coder: NSCoder) {
        nil
    }

    /// Shows the poster from the URL, or the placeholder when there is none.
    func showPoster(from url: URL?) {
        guard let url else {
            contentMode = .center
            image = UIImage(systemName: "film")
            return
        }

        contentMode = .scaleAspectFill
        loadTask = Task {
            image = await ImageLoader.shared.loadImage(from: url)
        }
    }

    /// Cancels the download and clears the image (used on cell reuse).
    func cancelLoading() {
        loadTask?.cancel()
        image = nil
    }
}
