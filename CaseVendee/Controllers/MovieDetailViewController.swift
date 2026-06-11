//
//  MovieDetailViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Detail screen in UIKit view code: poster, title, year, rating
/// and overview of the selected movie.
final class MovieDetailViewController: UIViewController {
    private let movie: Movie

    private let scrollView = UIScrollView()
    private let posterImageView = PosterImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let overviewLabel = UILabel()

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

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
