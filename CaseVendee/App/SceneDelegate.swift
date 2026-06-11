//
//  SceneDelegate.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 07/06/26.
//

import UIKit

/// Creates the window in code, since the project has no storyboards.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let listViewController = MovieListViewController()

        window.rootViewController = UINavigationController(
            rootViewController: listViewController
        )
        window.makeKeyAndVisible()

        self.window = window
    }
}
