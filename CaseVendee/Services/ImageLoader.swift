//
//  ImageLoader.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 11/06/26.
//

import UIKit

/// Downloads images and keeps them in an in-memory cache, so table
/// cells do not download the same poster twice while scrolling.
final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    /// Returns the cached image when available, otherwise downloads it.
    func loadImage(from url: URL) async -> UIImage? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
