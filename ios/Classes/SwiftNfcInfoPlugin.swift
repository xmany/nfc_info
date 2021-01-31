import Flutter
import UIKit
import CoreNFC

public class SwiftNfcInfoPlugin: NSObject, FlutterPlugin, FlutterStreamHandler{
  
  private var _eventSink: FlutterEventSink?
  private var _initialText: String?
  private var _latestText: String?

  private func setInitialText(text: String?) {
    _initialText = text;
  }
  
  private func setLatestText(text: String?) {
    _latestText = text
    if (_eventSink != nil)  {
      _eventSink?(_latestText)
    }
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftNfcInfoPlugin()
    
    // register message channel
    let channel = FlutterMethodChannel(name: "nfc_info", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // register event channel
    let eventChannel: FlutterEventChannel = FlutterEventChannel(name: "nfc_info_events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion);
    case "getInitialText":
        result(self._initialText);
    case "reset":
        setInitialText(text: nil)
        setLatestText(text: nil)
        result(nil);
    default:
        result(FlutterMethodNotImplemented);
    }
  }
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    let option = launchOptions[UIApplication.LaunchOptionsKey.url]
    if option != nil {
      let url = option as! URL
      setInitialText(text: url.absoluteString)
    } else {
      setInitialText(text: "application launch without URL in launch option")
    }
    return true
    
    
//    if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
//      _initialText = url.absoluteString
//      print("application() 1, get text from url: " + url.absoluteString)
//      return true;
//    } else if let activityDictionary = launchOptions[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] { //Universal link
//      for key in activityDictionary.keys {
//        if let userActivity = activityDictionary[key] as? NSUserActivity {
//          if let url = userActivity.webpageURL {
//            _initialText = url.absoluteString
//            print("application() 1, get text from universal url: " + url.absoluteString)
//            return true;
//          }
//        }
//      }
//    }
  }

  public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

    setLatestText(text: url.absoluteString)
    return true

  }
  
  private func application(_ application: UIApplication,
                           continue userActivity: NSUserActivity,
                           restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    // Confirm that the NSUserActivity object contains a valid NDEF message.
    if #available(iOS 12.0, *) {
      let ndefMessage: NFCNDEFMessage = userActivity.ndefMessagePayload
      guard ndefMessage.records.count > 0,
            ndefMessage.records[0].typeNameFormat != .empty else {
        print("empty ndef record, quit")
        return false
      }
      let text = String(decoding: ndefMessage.records[0].payload, as: UTF8.self)
      print("get ndef record0, nfc: " + text)
      setInitialText(text: text)
      setLatestText(text: text)
      return true
    } else {
      // Fallback on earlier versions
      let text = ""
      setInitialText(text: text)
      setLatestText(text: text)
      return false
    }
  }
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    _eventSink = events
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    _eventSink = nil
    return nil
  }
  
}
