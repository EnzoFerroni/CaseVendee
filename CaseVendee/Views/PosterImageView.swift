//
//  PosterImageView.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

// Image view that downloads and shows a movie poster.
// Used by both the list cell and the detail screen.
final class PosterImageView: UIImageView {

    // Keeps track of the current download so it can be cancelled.
    private var loadTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)

        // Crops the image to fill the frame without distortion.
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 8

        // Style for when there is no poster available.
        backgroundColor = .secondarySystemBackground
        tintColor = .secondaryLabel
        preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
    }

    // Required by UIKit but never used since the app has no storyboards.
    required init?(coder: NSCoder) {
        nil
    }

    // Downloads and shows the poster. Shows a film icon if there is no URL.
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

    // Cancels the download and clears the image.
    func cancelLoading() {
        loadTask?.cancel()
        image = nil
    }
}
