//
//  MovieCell.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Table cell built with view code: poster, title, year and rating.
final class MovieCell: UITableViewCell {
    static let identifier = "MovieCell"

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()

    /// Keeps the poster download so it can be cancelled on reuse.
    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        posterImageView.image = nil
    }

    /// Fills the cell with the movie data and loads its poster.
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        infoLabel.text = "\(movie.releaseYear)  ·  ★ " +
            String(format: "%.1f", movie.voteAverage)

        guard let posterURL = movie.posterURL else {
            return
        }

        imageTask = Task {
            posterImageView.image = await ImageLoader.shared.loadImage(from: posterURL)
        }
    }

    /// Builds the layout: poster on the left, labels stacked on the right.
    private func setupView() {
        accessoryType = .disclosureIndicator

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.backgroundColor = .secondarySystemBackground

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
