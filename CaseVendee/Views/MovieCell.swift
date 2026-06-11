//
//  MovieCell.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

// Table cell showing the poster, title, year and rating of a movie.
final class MovieCell: UITableViewCell {

    // Used by the table view to create and reuse cells of this type.
    static let identifier = "MovieCell"

    private let posterImageView = PosterImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    // Required by UIKit but never used since the app has no storyboards.
    required init?(coder: NSCoder) {
        nil
    }

    // Cancels the poster download when the cell is reused for a different movie.
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelLoading()
    }

    // Fills the cell with the movie data.
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        infoLabel.text = movie.summaryText
        posterImageView.showPoster(from: movie.posterURL)
    }

    // Builds the layout with the poster on the left and labels on the right.
    private func setupView() {
        accessoryType = .disclosureIndicator

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel

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
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 90),

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
