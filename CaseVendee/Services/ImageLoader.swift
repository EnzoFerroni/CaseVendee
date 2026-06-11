//
//  ImageLoader.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

// Downloads poster images and keeps them in memory to avoid downloading
// the same image again while the user scrolls.
final class ImageLoader {

    // Single instance shared across the whole app.
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func loadImage(from url: URL) async -> UIImage? {
        // Return the cached image if it was already downloaded.
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Download the image. Returns nil if the download fails,
        // so the placeholder stays visible instead of showing an error.
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
