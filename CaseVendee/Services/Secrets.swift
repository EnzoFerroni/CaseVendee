//
//  Secrets.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Reads build-time secrets injected via Secrets.xcconfig.
// To run the project, create Secrets.xcconfig with your own TMDb token.
enum Secrets {
    static let tmdbAccessToken: String = {
        guard let token = Bundle.main.infoDictionary?["TMDBAccessToken"] as? String,
              !token.isEmpty else {
            fatalError("TMDBAccessToken missing. Add Secrets.xcconfig with your token.")
        }
        return token
    }()
}
