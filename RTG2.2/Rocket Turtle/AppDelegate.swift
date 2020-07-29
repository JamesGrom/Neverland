//
//  AppDelegate.swift
//  Rocket Turtle
//
//  Created by James Grom on 6/30/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
//import MapboxMobileEvents
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        FirebaseApp.configure()
        let db = Firestore.firestore()
        print(db)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerForPushNotifications(){
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert,.sound,.badge]){
                granted, error in
                print("permission granted: \(granted)")
        }
    }


}

