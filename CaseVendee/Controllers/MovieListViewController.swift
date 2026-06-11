//
//  MovieListViewController.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

// Main screen with the movie list, search bar and release year filter.
// This class only handles layout and user events. All data lives in the view model.
final class MovieListViewController: UIViewController {

    // Holds all the data and logic for this screen.
    private let viewModel = MovieListViewModel()

    // Table that shows the list of movies.
    private let tableView = UITableView()

    // Search bar shown inside the navigation bar.
    private let searchController = UISearchController()

    // Spinner shown while a request is loading.
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // Message shown behind the table when a search returns no movies.
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.loadPopularMovies()
    }

    // MARK: - Setup

    // Builds the navigation bar, search bar and table.
    private func setupView() {
        title = "Movies"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = makeFilterButton()

        searchController.searchBar.placeholder = "Search movies"
        searchController.searchBar.delegate = self
        // Keeps the navigation bar visible while the user types.
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = "No movies found"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.adjustsFontForContentSizeCategory = true

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Connects the view model callbacks to UI updates.
    // weak self prevents a retain cycle between the controller and the view model.
    private func setupBindings() {
        viewModel.onMoviesUpdated = { [weak self] in
            guard let self else {
                return
            }

            tableView.reloadData()
            // Shows the empty message only when there are no movies.
            tableView.backgroundView = viewModel.movies.isEmpty ? emptyLabel : nil
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }

        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            }
            else {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - Year filter

    // Creates the filter button with a menu listing recent years.
    private func makeFilterButton() -> UIBarButtonItem {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Array((currentYear - 10)...currentYear).reversed()

        // First option removes the filter and shows all years.
        var actions = [
            UIAction(title: "All years") { [weak self] _ in
                self?.applyYearFilter(nil)
            }
        ]

        // One option per year, newest first.
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

    // Saves the selected year and refreshes the results.
    private func applyYearFilter(_ year: Int?) {
        viewModel.selectedYear = year
        searchMovies()
    }

    // Asks the view model to search using the current search bar text.
    private func searchMovies() {
        viewModel.searchMovies(query: searchController.searchBar.text ?? "")
    }

    // Shows an alert with the error message.
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Erro", message: message, preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MovieListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieCell.identifier, for: indexPath
        )

        // Falls back to an empty cell if the cast fails, instead of crashing.
        guard let movieCell = cell as? MovieCell else {
            return cell
        }

        movieCell.configure(with: viewModel.movies[indexPath.row])

        return movieCell
    }
}

// MARK: - UITableViewDelegate

extension MovieListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Removes the selection highlight when coming back to this screen.
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = viewModel.movies[indexPath.row]
        let detailViewController = MovieDetailViewController(movie: movie)

        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MovieListViewController: UISearchBarDelegate {

    // Searches when the user taps the Search button on the keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMovies()
    }

    // Goes back to the popular list when the user cancels the search.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.loadPopularMovies()
    }
}
