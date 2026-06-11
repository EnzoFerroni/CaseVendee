//
//  SceneDelegate.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 07/06/26.
//

import UIKit

/// Creates the window in code, since the project has no storyboards.
///
/// This is the only part that differs from the Xcode template: the
/// template lets the storyboard create the window, while here the
/// window and its root view controller are built manually.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    /// Strong reference required to keep the window alive — nothing
    /// else retains it after `scene(_:willConnectTo:options:)` returns.
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // The scene must be a window scene to host a UIWindow.
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // Window attached to the scene, with the movie list wrapped
        // in a navigation controller (needed for the push to the
        // detail screen).
        let window = UIWindow(windowScene: windowScene)
        let listViewController = MovieListViewController()

        window.rootViewController = UINavigationController(
            rootViewController: listViewController
        )
        window.makeKeyAndVisible()

        self.window = window
    }
}
