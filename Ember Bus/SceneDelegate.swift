//
//  SceneDelegate.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let busMapView = BusMapView()

        // UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: busMapView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

}
