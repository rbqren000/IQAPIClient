//
//  AppDelegate.swift
//  API Client
//
//  Created by Iftekhar on 09/09/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient
import Alamofire
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureAPIClient()
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func configureAPIClient() {

        func topViewController() -> UIViewController? {
            var parentController = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
            while parentController != nil, let newParent = parentController?.presentedViewController {
                parentController = newParent
            }
            return parentController
        }

        IQAPIClient.baseURL = URL(string: "https://reqres.in/api")
        IQAPIClient.httpHeaders["Content-Type"] = "application/json"
        IQAPIClient.httpHeaders["Accept"] = "application/json"
        IQAPIClient.debuggingEnabled = true

        // Common error handler block is common for all requests, so we could just write UIAlertController
        // presentation logic at single place for showing error from any API response.
        IQAPIClient.commonErrorHandlerBlock = { (_, _, _, error) in

            switch (error as NSError).code {
            case NSURLClientError.unauthorized401.rawValue:

                let window: UIWindow?
                #if swift(>=5.1)
                if #available(iOS 13, *) {
                    window = UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }.first(where: { $0.isKeyWindow })
                } else {
                    window = UIApplication.shared.keyWindow
                }
                #else
                window = UIApplication.shared.keyWindow
                #endif

                window?.rootViewController?.dismiss(animated: true, completion: nil)

            default:
                let alertController = UIAlertController(title: "Error!",
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                topViewController()?.present(alertController, animated: true, completion: nil)
            }
        }

        IQAPIClient.responseModifierBlock = { (_, response) in

            guard let response = response as? [String: Any] else {
                let error = NSError(domain: "ServerError", code: NSURLErrorBadServerResponse,
                                    userInfo: [NSLocalizedDescriptionKey: IQAPIClient.unintentedResponseErrorMessage])
               return .error(error)
            }

            if let data = response["data"] as? [String: Any] {
                if data.count == 0 {
                    let error = NSError(domain: "ServerError", code: NSURLClientError.notFound404.rawValue,
                                        userInfo: [NSLocalizedDescriptionKey: "Record does not exist"])
                    return .failure(error)
                } else {
                    return .success(data)
                }
            } else if let data = response["data"] as? [[String: Any]] {
                return .success(data)
            } else {
                let error = NSError(domain: "ServerError", code: NSURLErrorBadServerResponse,
                                    userInfo: [NSLocalizedDescriptionKey: IQAPIClient.unintentedResponseErrorMessage])
               return .error(error)
            }
        }
    }
}
