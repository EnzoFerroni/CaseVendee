//
//  ImageLoader.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Downloads images and keeps them in an in-memory cache.
///
/// Table view cells are reused while the user scrolls, so the same
/// poster would be downloaded many times without a cache. `NSCache`
/// was chosen over a dictionary because the system empties it
/// automatically under memory pressure — a simple answer to the
/// memory-management requirement of the project.
final class ImageLoader {
    /// Shared instance, so every screen reuses the same cache.
    static let shared = ImageLoader()

    /// Cache keyed by image URL. `NSCache` requires class types,
    /// hence `NSURL`/`UIImage` instead of their value-type versions.
    private let cache = NSCache<NSURL, UIImage>()

    /// Private so the singleton is the only possible instance.
    private init() {}

    /// Returns the cached image when available, otherwise downloads it.
    ///
    /// - Parameter url: Full URL of the image.
    /// - Returns: The image, or `nil` when the download or decoding
    ///   fails — callers then simply keep their placeholder.
    func loadImage(from url: URL) async -> UIImage? {
        // Cache hit: return immediately, no network involved.
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Cache miss: download and decode. `try?` turns any network
        // error into `nil` because a missing poster is not a failure
        // worth interrupting the user for.
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        // Store for the next request of the same URL.
        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
