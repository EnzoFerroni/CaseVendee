//
//  MovieListViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Main screen: movie table, search bar and release-year filter.
/// UI layer only — data and logic live in `MovieListViewModel`.
final class MovieListViewController: UIViewController {
    private let viewModel = MovieListViewModel()
    private let tableView = UITableView()
    private let searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.loadPopularMovies()
    }

    // MARK: - Setup

    /// Builds the layout in view code: navigation bar, search and table.
    private func setupView() {
        title = "Movies"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = makeFilterButton()

        searchController.searchBar.placeholder = "Search movies"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    /// Connects the view model callbacks to UI updates.
    /// `weak self` avoids a retain cycle between view and view model.
    private func setupBindings() {
        viewModel.onMoviesUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    // MARK: - Year filter

    /// Creates the filter button with a menu of the last 10 years.
    private func makeFilterButton() -> UIBarButtonItem {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Array((currentYear - 10)...currentYear).reversed()

        var actions = [
            UIAction(title: "All years") { [weak self] _ in
                self?.applyYearFilter(nil)
            }
        ]

        actions += years.map { year in
            UIAction(title: String(year)) { [weak self] _ in
                self?.applyYearFilter(year)
            }
        }

        return UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            menu: UIMenu(title: "Release year", children: actions)
        )
    }

    private func applyYearFilter(_ year: Int?) {
        viewModel.selectYear(year)
        searchMovies()
    }

    private func searchMovies() {
        viewModel.searchMovies(query: searchController.searchBar.text ?? "")
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Oops", message: message, preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MovieListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.movies.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieCell.identifier, for: indexPath
        )

        guard let movieCell = cell as? MovieCell else {
            return cell
        }

        movieCell.configure(with: viewModel.movies[indexPath.row])

        return movieCell
    }
}

// MARK: - UITableViewDelegate

extension MovieListViewController: UITableViewDelegate {
    /// Opens the detail screen for the tapped movie.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = viewModel.movies[indexPath.row]
        let detailViewController = MovieDetailViewController(movie: movie)

        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MovieListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMovies()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.loadPopularMovies()
    }
}
