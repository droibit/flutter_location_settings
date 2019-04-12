import Flutter
import UIKit
import CoreLocation

public class SwiftFlutterLocationSettingsPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.github.droibit.flutter.plugins.flutter_location_settings",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftFlutterLocationSettingsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkLocationEnabled":
            result(CLLocationManager.locationServicesEnabled())
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
}
