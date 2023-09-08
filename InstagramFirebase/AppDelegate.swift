//
//  AppDelegate.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 16.03.23.
//

import UIKit
import FirebaseCore
//import FirebaseMessaging
//import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
     //   attemptRegisterForNotifications(application: application)
        return true
    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        print("REgidtered for notifications: ",deviceToken)
//    }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("REgidtered with FCM with token: ", fcmToken ?? "")
//    }
//
//    fileprivate func attemptRegisterForNotifications(application: UIApplication) {
//        print("Attempting to register APNS..")
//
//        Messaging.messaging().delegate = self
//
//        // user notifications auth
//        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, err in
//            if let err = err {
//                print("Failed to request auth: ", err)
//                return
//            }
//
//            if granted {
//                print("auth granted")
//            } else {
//                print("auth denied")
//            }
//        }
//        application.registerForRemoteNotifications()
//    }

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


}

