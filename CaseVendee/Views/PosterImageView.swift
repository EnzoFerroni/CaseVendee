//
//  PosterImageView.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Poster component shared by the list cell and the detail screen.
///
/// Encapsulates everything a poster needs in one place: the download
/// (through ``ImageLoader``), the cancellation of an in-flight
/// download, and the fallback to a film symbol when the movie has no
/// poster registered on TMDb.
final class PosterImageView: UIImageView {
    /// Current download, kept so it can be cancelled on cell reuse.
    private var loadTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)

        // `scaleAspectFill` + `clipsToBounds` crops the image to fill
        // the frame without distortion.
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 8

        // Visual style of the "no poster" state: a soft background
        // with a gray symbol sized like a title.
        backgroundColor = .secondarySystemBackground
        tintColor = .secondaryLabel
        preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
    }

    /// Never called: the app builds every view in code. Returning
    /// `nil` avoids the usual `fatalError` boilerplate.
    required init?(coder: NSCoder) {
        nil
    }

    /// Shows the poster from the URL, or the placeholder when `nil`.
    ///
    /// - Parameter url: Full poster URL, usually `Movie.posterURL`.
    func showPoster(from url: URL?) {
        guard let url else {
            // No poster on TMDb: center a film symbol instead.
            contentMode = .center
            image = UIImage(systemName: "film")
            return
        }

        contentMode = .scaleAspectFill

        // The download runs in a Task so the UI never blocks; the
        // image is set whenever it arrives (or stays empty on failure).
        loadTask = Task {
            image = await ImageLoader.shared.loadImage(from: url)
        }
    }

    /// Cancels the download and clears the image.
    ///
    /// Called from `prepareForReuse` so a recycled cell never shows
    /// the poster of the movie it displayed before.
    func cancelLoading() {
        loadTask?.cancel()
        image = nil
    }
}
