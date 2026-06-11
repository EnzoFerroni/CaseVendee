//
//  MovieDetailViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Detail screen in UIKit view code: poster, title, year, rating
/// and overview of the selected movie.
///
/// The screen is read-only and receives the ``Movie`` it displays
/// through the initializer, so it has no logic beyond layout —
/// no view model is needed here.
final class MovieDetailViewController: UIViewController {
    /// Movie being displayed, injected by the list screen.
    private let movie: Movie

    /// Allows the content to scroll when the overview is long or the
    /// user increases the system font size.
    private let scrollView = UIScrollView()

    /// Shared poster component (download, cache and placeholder).
    private let posterImageView = PosterImageView()

    /// Movie title, allowed to wrap in multiple lines.
    private let titleLabel = UILabel()

    /// Secondary "year · rating" line.
    private let infoLabel = UILabel()

    /// Full synopsis of the movie.
    private let overviewLabel = UILabel()

    /// - Parameter movie: Movie selected on the list screen.
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    /// Never called: the app builds every view in code. Returning
    /// `nil` avoids the usual `fatalError` boilerplate.
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showMovie()
    }

    /// Builds the layout: a vertical stack inside a scroll view.
    private func setupView() {
        view.backgroundColor = .systemBackground

        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 0

        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel

        overviewLabel.font = .preferredFont(forTextStyle: .body)
        overviewLabel.numberOfLines = 0

        // One vertical stack holds the whole content, so the scroll
        // view only needs to track a single subview.
        let stack = UIStackView(arrangedSubviews: [
            posterImageView, titleLabel, infoLabel, overviewLabel
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            // Scroll view fills the screen.
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // The stack pinned to the scroll view's content guide
            // defines the scrollable area (with 16pt of padding)...
            stack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16
            ),
            stack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16
            ),
            stack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16
            ),
            stack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16
            ),

            // ...and matching the frame guide width locks the scroll
            // to vertical only (32 = the two side paddings).
            stack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32
            ),

            // Movie posters use the standard 2:3 aspect ratio.
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor, multiplier: 1.5
            )
        ])
    }

    /// Fills the views with the movie data.
    private func showMovie() {
        titleLabel.text = movie.title
        infoLabel.text = movie.summaryText
        overviewLabel.text = movie.overview.isEmpty
            ? "No overview available."
            : movie.overview
        posterImageView.showPoster(from: movie.posterURL)
    }
}
