//
//  MovieDetailViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

// Shows the details of a selected movie.
// This screen only displays data, so it has no view model.
final class MovieDetailViewController: UIViewController {

    // The movie passed in from the list screen.
    private let movie: Movie

    // Makes the content scrollable when the overview is long.
    private let scrollView = UIScrollView()

    // Downloads and shows the movie poster.
    private let posterImageView = PosterImageView()

    // Movie title, can wrap into multiple lines.
    private let titleLabel = UILabel()

    // Shows the release year and rating on a single line.
    private let infoLabel = UILabel()

    // Full synopsis of the movie.
    private let overviewLabel = UILabel()

    // Receives the movie from the list screen.
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    // Required by UIKit but never used since the app has no storyboards.
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showMovie()
    }

    // Builds the layout with a vertical stack inside a scroll view.
    private func setupView() {
        view.backgroundColor = .systemBackground

        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 0

        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel

        overviewLabel.font = .preferredFont(forTextStyle: .body)
        overviewLabel.numberOfLines = 0

        // A single stack holds all content so the scroll view
        // only needs to manage one subview.
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
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Pin the stack to the scroll content area with padding on all sides.
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

            // Matching the stack width to the visible area prevents horizontal scrolling.
            stack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32
            ),

            // Keeps the poster at the standard movie aspect ratio.
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor, multiplier: 1.5
            )
        ])
    }

    // Fills each view with the movie data.
    private func showMovie() {
        titleLabel.text = movie.title
        infoLabel.text = movie.summaryText
        overviewLabel.text = movie.overview.isEmpty ? "No overview available." : movie.overview
        posterImageView.showPoster(from: movie.posterURL)
    }
}
