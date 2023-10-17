//
//  PRtifyAppDelegate+UIApplicationDelegate.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import UIKit
import Pulse

extension PRtifyAppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        enableAutomaticRegistration()
        
        return true
    }
    
    func configureNavigationBar(_ navigationController: UINavigationController) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationBarAppearance.backgroundColor = .flatDarkBackground
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationController.navigationBar.compactAppearance = navigationBarAppearance
        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
    }
    
    private func enableAutomaticRegistration() {
        URLSessionProxyDelegate.enableAutomaticRegistration()
        logger.info("✅ Pulse automatic registration has been enabled")
    }
}
