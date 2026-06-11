# CaseVendee

[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg?style=flat)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org)
[![UIKit](https://img.shields.io/badge/UIKit-View%20Code-green.svg?style=flat)](https://developer.apple.com/documentation/uikit)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-red.svg?style=flat)](#architecture)

iOS app written in UIKit with view code that consumes the [TMDb API](https://www.themoviedb.org). The main screen lists popular movies with text search and a release-year filter. Tapping a movie opens a detail screen with poster, year, rating and overview.

## Screenshots

| Popular movies | Year filter | Search | Detail |
| --- | --- | --- | --- |
| ![Movie list](Screenshots/movie-list.png) | ![Year filter](Screenshots/year-filter.png) | ![Search](Screenshots/search.png) | ![Movie detail](Screenshots/movie-detail.png) |

## Requirements

- Xcode 26 or later
- iOS 26 or later
- A free [TMDb account](https://www.themoviedb.org/signup) to generate an API token

## Getting Started

**1. Clone the repository**

```bash
git clone https://github.com/EnzoFerroni/CaseVendee.git
cd CaseVendee
```

**2. Add your TMDb token**

The token is kept out of version control. Create `CaseVendee/Secrets.xcconfig` with your own token (themoviedb.org → Settings → API → "API Read Access Token"):

```
TMDB_ACCESS_TOKEN = your_token_here
```

Then open `CaseVendee.xcodeproj`, go to the project settings → Info → Configurations, and set `Secrets` as the configuration file for both Debug and Release.

**3. Run**

Select an iOS Simulator and press Run. No package resolution or extra setup is needed.

## Architecture

The app follows **MVVM**. The view controller belongs to the View layer — it only builds the layout and forwards user events. All state and logic live in the view model, and networking in a dedicated service layer.

```
CaseVendee/
├── App/             AppDelegate, SceneDelegate
├── Models/          Movie, MovieResponse
├── Services/        MovieService, ImageLoader
├── ViewModels/      MovieListViewModel
├── Views/           MovieCell, PosterImageView
└── Controllers/     MovieListViewController, MovieDetailViewController
```

The view model notifies the view through two closures (`onMoviesUpdated`, `onError`) — no third-party framework needed.

## Technical Decisions

**UIKit with view code**
Every layout is built with Auto Layout in code. The window itself is created programmatically in `SceneDelegate`, which is the only difference from the Xcode template. No `.xib` or `.storyboard` files are used.

**`final class` on every type**
All classes are marked `final` because none of them are designed to be subclassed. This tells the compiler to use direct dispatch instead of dynamic dispatch on every method call, and communicates intent clearly to anyone reading the code.

**Memory management**
`[weak self]` is used in every closure where the view controller is captured — specifically in the view model bindings and in the year filter menu actions — to avoid retain cycles. The view model owns the closures, and without `weak self` the view controller would be kept alive indefinitely after the screen closes.

**Poster image cache**
`ImageLoader` uses `NSCache` to keep downloaded posters in memory. Unlike a plain dictionary, `NSCache` is automatically purged by the system under memory pressure, which makes it a safe choice for image caching without manual eviction logic.

**Cell reuse and task cancellation**
`UITableViewCell` instances are recycled as the user scrolls. `PosterImageView` keeps a reference to its active download `Task` and cancels it in `prepareForReuse`. Without this, a cell recycled for a new row could briefly show the poster of the previous movie while the new download completes.

**`@MainActor` on the view model**
`MovieListViewModel` is annotated with `@MainActor`, which guarantees that every property change and closure callback runs on the main thread. UIKit requires all UI updates to happen on the main thread — this annotation enforces that automatically instead of relying on manual `DispatchQueue.main.async` calls.

**`async/await` networking**
All TMDb requests use `URLSession` with `async/await`. The view model wraps each call in a `Task` so it can be triggered from synchronous UIKit code like `viewDidLoad`. Errors are caught and forwarded to the view through the `onError` closure.

**API token security**
The TMDb token is injected at build time via `Secrets.xcconfig`, which is gitignored. At runtime, `Secrets.swift` reads the token from `Bundle.main.infoDictionary`. This keeps the key out of version control while remaining straightforward for local development.
