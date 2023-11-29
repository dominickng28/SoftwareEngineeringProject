import UIKit
import Flutter
// import FlutterAppAuth


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
// @available(iOS 9.0, *)
// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     if #available(iOS 9.0, *) {
//       GeneratedPluginRegistrant.register(with: self)
//     }
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }

//   @available(iOS 13.0, *)
//   override func application(
//     _ app: UIApplication,
//     open url: URL,
//     options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//   ) -> Bool {
//     if #available(iOS 13.0, *) {
//       return FlutterAppAuthPlugin.instance().application(app, open: url, options: options)
//     } else {
//       return false
//     }
//   }
// }
