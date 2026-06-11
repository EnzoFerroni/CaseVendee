//
//  MovieListViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Main screen: movie table, search bar and release-year filter.
///
/// In MVVM the view controller belongs to the View layer: this class
/// only builds the layout and forwards user events. All data and
/// logic live in ``MovieListViewModel``.
final class MovieListViewController: UIViewController {
    /// Source of truth of the screen (movies, search, filter).
    private let viewModel = MovieListViewModel()

    /// Table that displays one ``MovieCell`` per movie.
    private let tableView = UITableView()

    /// System search controller shown inside the navigation bar.
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
        // Keeps the navigation bar (and the filter button) visible
        // while the user is typing a search.
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        // The table fills the whole screen; the safe area is handled
        // automatically by the table view content insets.
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    /// Connects the view model callbacks to UI updates.
    ///
    /// `[weak self]` breaks the reference cycle that would otherwise
    /// exist: the controller owns the view model, and the view model
    /// would own the controller back through these closures.
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
    ///
    /// `UIMenu` attached to a bar button is the standard iOS pattern
    /// for a small list of options — no custom screen needed.
    ///
    /// - Returns: The configured bar button item.
    private func makeFilterButton() -> UIBarButtonItem {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Array((currentYear - 10)...currentYear).reversed()

        // First option clears the filter ("All years")...
        var actions = [
            UIAction(title: "All years") { [weak self] _ in
                self?.applyYearFilter(nil)
            }
        ]

        // ...followed by one action per year, newest first.
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

    /// Stores the chosen year and refreshes the current results.
    ///
    /// - Parameter year: Selected year, or `nil` for "All years".
    private func applyYearFilter(_ year: Int?) {
        viewModel.selectedYear = year
        searchMovies()
    }

    /// Asks the view model to search with the current search bar text.
    private func searchMovies() {
        viewModel.searchMovies(query: searchController.searchBar.text ?? "")
    }

    /// Presents a simple alert with the given error message.
    ///
    /// - Parameter message: User-friendly text from the view model.
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
    /// One row per movie held by the view model.
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.movies.count
    }

    /// Dequeues a reusable ``MovieCell`` and fills it with the movie
    /// of the requested row.
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieCell.identifier, for: indexPath
        )

        // `guard` instead of force cast: if the cast ever fails the
        // app shows an empty cell instead of crashing.
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
        // Removes the gray selection highlight when coming back.
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = viewModel.movies[indexPath.row]
        let detailViewController = MovieDetailViewController(movie: movie)

        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MovieListViewController: UISearchBarDelegate {
    /// Searches when the user taps the keyboard "Search" button.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMovies()
    }

    /// Restores the popular list when the search is cancelled.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.loadPopularMovies()
    }
}
