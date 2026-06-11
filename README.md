# CaseVendee

[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg?style=flat)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org)
[![UIKit](https://img.shields.io/badge/UIKit-View%20Code-green.svg?style=flat)](https://developer.apple.com/documentation/uikit)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-red.svg?style=flat)](#architecture)

CaseVendee is an iOS app, written **100% in UIKit with view code**, that
consumes [The Movie Database (TMDb)](https://www.themoviedb.org) API. The
main screen lists popular movies in a `UITableView` and supports text search
with custom parameters (release-year filter, pt-BR localized results).
Tapping a movie opens a detail screen with poster, year, rating and overview.

## Screenshots

| Popular movies | Year filter | Search | Detail |
| --- | --- | --- | --- |
| ![Movie list](Screenshots/movie-list.png) | ![Year filter](Screenshots/year-filter.png) | ![Search](Screenshots/search.png) | ![Movie detail](Screenshots/movie-detail.png) |

## Features

- Popular movies list consuming the TMDb API
- Search by text with custom parameters (`query`, `primary_release_year`, `language`)
- Release-year filter available in the navigation bar (`UIMenu`)
- Movie detail screen with poster, year, rating and overview
- Poster image download with in-memory cache (`NSCache`) and a
  placeholder symbol for movies without a poster
- No external dependencies — 100% native frameworks

## Requirements

- Xcode 26 or later
- iOS 26 or later
- A free TMDb account to generate an API token

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/EnzoFerroni/CaseVendee.git
cd CaseVendee
```

### 2. Create your Secrets file

The TMDb token is kept out of version control. Create
`CaseVendee/Services/Secrets.swift` with your own token
(themoviedb.org > Settings > API > "API Read Access Token"):

```swift
import Foundation

enum Secrets {
    static let tmdbAccessToken = "YOUR_TMDB_V4_READ_ACCESS_TOKEN"
}
```

### 3. Run

Open `CaseVendee.xcodeproj`, select an iOS Simulator and press Run.
No package resolution or extra setup is needed.

## Architecture

The app follows **MVVM**. In UIKit, the view controller belongs to the View
layer: it only builds the layout and forwards user events, while state and
logic live in the view model, and networking in a dedicated service.

Files are grouped by layer:

```
CaseVendee/
├── App/             AppDelegate, SceneDelegate (window in code)
├── Models/          Movie, MovieResponse (Decodable)
├── Services/        MovieService (TMDb requests), ImageLoader (poster cache)
├── ViewModels/      MovieListViewModel (list state, search, year filter)
├── Views/           MovieCell, PosterImageView (shared poster component)
└── Controllers/     MovieListViewController, MovieDetailViewController
```

The view model notifies the view through closures (`onMoviesUpdated`,
`onError`) — the simplest binding mechanism for MVVM in UIKit, with no
third-party frameworks.

## Technical Decisions

- **View code, no storyboards**: the window is created programmatically in
  `SceneDelegate` and every layout uses Auto Layout in code, as required by
  the position.
- **Shared poster component**: `PosterImageView` encapsulates download,
  cache, cancellation and the no-poster placeholder, and is reused by the
  list cell and the detail screen.
- **async/await networking**: modern concurrency with `URLSession`,
  authenticated with a TMDb v4 token via `Authorization: Bearer` header.
- **Memory management**: `[weak self]` in every closure to avoid retain
  cycles, poster downloads cancelled on cell reuse, and `NSCache` for images
  (automatically purged under memory pressure).

## API

[TMDb API v3](https://developer.themoviedb.org/docs) endpoints used:

| Endpoint | Purpose |
| --- | --- |
| `GET /discover/movie` | Main list, sorted by popularity, year filter |
| `GET /search/movie` | Search with `query` and `primary_release_year` |

## Code Style

The codebase follows the Academy Coding Standards: English naming, K&R
braces, 4-space indentation, `guard let` over `if let`, no force unwrapping,
and commits prefixed with `feat:` / `fix:` / `remove:` / `refactor:`.
