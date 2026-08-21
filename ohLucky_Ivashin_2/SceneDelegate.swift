//
//  SceneDelegate.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivashin Ivan on 19.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MenuController()
        window.makeKeyAndVisible()

        self.window = window
    }
}

