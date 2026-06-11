//
//  MovieCell.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Table cell built with view code: poster, title, year and rating.
final class MovieCell: UITableViewCell {
    /// Reuse identifier used by `register`/`dequeue` on the table view.
    static let identifier = "MovieCell"

    /// Shared poster component (download, cache and placeholder).
    private let posterImageView = PosterImageView()

    /// Movie title, up to two lines.
    private let titleLabel = UILabel()

    /// Secondary "year · rating" line.
    private let infoLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    /// Never called: the app builds every view in code. Returning
    /// `nil` avoids the usual `fatalError` boilerplate.
    required init?(coder: NSCoder) {
        nil
    }

    /// Cells are recycled while the user scrolls; cancelling the
    /// download here prevents a poster from a previous movie from
    /// appearing on the wrong row.
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelLoading()
    }

    /// Fills the cell with the movie data and loads its poster.
    ///
    /// - Parameter movie: Movie of the row being displayed.
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        infoLabel.text = movie.summaryText
        posterImageView.showPoster(from: movie.posterURL)
    }

    /// Builds the layout in code: poster on the left, labels stacked
    /// vertically on the right.
    private func setupView() {
        // Chevron on the right edge, hinting the row opens a detail.
        accessoryType = .disclosureIndicator

        // Text styles (instead of fixed sizes) follow the system font
        // settings, as recommended by the HIG.
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel

        // Stacks avoid writing one constraint per subview: the
        // vertical stack arranges the labels, the horizontal one
        // places the poster beside them.
        let textStack = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [posterImageView, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            // Fixed poster size keeps every row the same height.
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 90),

            // The stack fills the cell, respecting the system margins
            // on the sides; top/bottom define the row height.
            mainStack.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 8
            ),
            mainStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -8
            ),
            mainStack.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ),
            mainStack.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            )
        ])
    }
}
