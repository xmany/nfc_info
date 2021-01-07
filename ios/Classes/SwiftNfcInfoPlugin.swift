import Flutter
import UIKit
import CoreNFC

public class SwiftNfcInfoPlugin: NSObject, FlutterPlugin {

  private var initialText: String? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nfc_info", binaryMessenger: registrar.messenger())
    let instance = SwiftNfcInfoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("handle(), "+call.method)
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion);
    case "getInitialText":
        result(self.initialText);
    case "reset":
        self.initialText = nil
        result(nil);
    default:
        result(FlutterMethodNotImplemented);
    }
  }
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
      initialText = url.absoluteString
      print("application() 1, get text from url: " + url.absoluteString)
      return true;
    } else if let activityDictionary = launchOptions[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] { //Universal link
      for key in activityDictionary.keys {
        if let userActivity = activityDictionary[key] as? NSUserActivity {
          if let url = userActivity.webpageURL {
            initialText = url.absoluteString
            print("application() 1, get text from universal url: " + url.absoluteString)
            return true;
          }
        }
      }
    }
    return false
  }

  public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    initialText = url.absoluteString
    print("application() 2, get text from url: " + url.absoluteString)
    return true;
  }
  
  private func application(_ application: UIApplication,
                           continue userActivity: NSUserActivity,
                           restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    print("application() 3, " + userActivity.activityType)
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
      let url = userActivity.webpageURL?.absoluteString ?? ""
      print("application() 3, web browsing, web url: " + url)
      return false
    }
    // Confirm that the NSUserActivity object contains a valid NDEF message.
    if #available(iOS 12.0, *) {
      let ndefMessage: NFCNDEFMessage = userActivity.ndefMessagePayload
      guard ndefMessage.records.count > 0,
            ndefMessage.records[0].typeNameFormat != .empty else {
        return false
      }
      initialText = String(decoding: ndefMessage.records[0].payload, as: UTF8.self)
      print("application() 3, get nfc: " + (initialText ?? "null"))
    } else {
      // Fallback on earlier versions
      initialText = ""
    }
    
    // Send the message to `MessagesTableViewController` for processing.
    //    guard let navigationController = window?.rootViewController as? UINavigationController else {
    //        return false
    //    }
    //
    //    navigationController.popToRootViewController(animated: true)
    //    let messageTableViewController = navigationController.topViewController as? MessagesTableViewController
    //    messageTableViewController?.addMessage(fromUserActivity: ndefMessage)
    
    return true
  }
}
