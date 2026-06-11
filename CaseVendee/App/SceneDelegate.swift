//
//  SceneDelegate.swift
//  CaseVendee
//
//  Created by Enzo Ferroni on 07/06/26.
//

import UIKit

// Sets up the app window in code since the project has no storyboard.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // This property holds the window so it stays alive while the app runs.
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)

        // The navigation controller lets the app open the detail screen
        // on top of the movie list.
        window.rootViewController = UINavigationController(
            rootViewController: MovieListViewController()
        )
        window.makeKeyAndVisible()

        self.window = window
    }
}
