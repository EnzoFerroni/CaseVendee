# CaseVendee

iOS app for the Vendee selection case: browses TMDb movies in a UIKit
table built with view code, with search and a release-year filter.
Tapping a movie opens a SwiftUI detail screen hosted in a
`UIHostingController`, showing a gradual UIKit-to-SwiftUI migration.

## Architecture

MVVM. The view controller only renders state and forwards user events;
data and logic live in the view model, and networking in a service.

```
Models/       Movie (Decodable)
Services/     MovieService (TMDb requests), ImageLoader (poster cache)
ViewModels/   MovieListViewModel (list state, search, year filter)
Views/        MovieCell (view code), MovieDetailView (SwiftUI)
Controllers/  MovieListViewController (UI only)
```

## Running the project

The TMDb token is not versioned. Before building, create
`CaseVendee/Services/Secrets.swift`:

```swift
import Foundation

enum Secrets {
    static let tmdbAccessToken = "YOUR_TMDB_V4_READ_ACCESS_TOKEN"
}
```

Get a token at themoviedb.org > Settings > API. Then open
`CaseVendee.xcodeproj` and run.
