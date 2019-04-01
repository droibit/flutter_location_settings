import Flutter
import UIKit
import CoreLocation

private typealias ExpectAuthorizationStatus = (value: CLAuthorizationStatus, request: () -> Void)

public class SwiftFlutterLocationSettingsPlugin: NSObject, FlutterPlugin {
    
    private static let KEY_SHOW_DIALOG = "showDialog"
    private static let KEY_AUTHORIZATION = "authorization"
    
    private static let AUTHORIZATION_ALWAYS = 0
    private static let AUTHORIZATION_WHEN_IN_USE = 1
    
    private let locationManager: CLLocationManager
    
    private var pendingResult: FlutterResult? = nil
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
 
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "com.github.droibit.flutter.plugins.flutter_location_settings",
        binaryMessenger: registrar.messenger()
    )
    let instance = SwiftFlutterLocationSettingsPlugin(locationManager: CLLocationManager())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkLocationEnabled":
        checkLocationEnabled(with: call.arguments as! Dictionary<String, AnyObject>, result: result)
        break
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func checkLocationEnabled(with option: Dictionary<String, AnyObject>, result: @escaping FlutterResult) {
        guard let authorization = option[SwiftFlutterLocationSettingsPlugin.KEY_AUTHORIZATION] as? Int else {
            result(FlutterError(code: "ERROR", message: "Option does not include the `authorization`.", details: nil))
            return
        }
        
        let expectStatus: ExpectAuthorizationStatus
        switch authorization {
        case SwiftFlutterLocationSettingsPlugin.AUTHORIZATION_ALWAYS:
            expectStatus = (value: CLAuthorizationStatus.authorizedAlways,
                            request: locationManager.requestAlwaysAuthorization)
            break
        case SwiftFlutterLocationSettingsPlugin.AUTHORIZATION_WHEN_IN_USE:
            expectStatus = (value: CLAuthorizationStatus.authorizedWhenInUse,
                            request: locationManager.requestWhenInUseAuthorization)
            break
        default:
            result(FlutterError(code: "ERROR", message: "Invalid `authorization`: \(authorization).", details: nil))
            return
        }
        
        let currentStauts = CLLocationManager.authorizationStatus()
        if currentStauts == expectStatus.value {
            result(currentStauts.toResultValue())
            return
        }
        
        let showDialog = option[SwiftFlutterLocationSettingsPlugin.KEY_SHOW_DIALOG] as? Bool
        if (showDialog != true) {
            result(currentStauts.toResultValue())
            return
        }
        
        pendingResult = result
        locationManager.delegate = self
        if (currentStauts == .notDetermined) {
            expectStatus.request()
        } else {
            // TODO: Is it possible to show setting app from this app?
            result(currentStauts.toResultValue())
            pendingResult = nil
        }
    }
}

extension SwiftFlutterLocationSettingsPlugin: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        pendingResult?(status.toResultValue())
        pendingResult = nil
    }
}

private extension CLAuthorizationStatus {
    
    private static let RESULT_NOT_DETERMINED = 0
    private static let RESULT_RESTRICTED = 1
    private static let RESULT_DENIED = 2
    private static let RESULT_AUTHORIZED_ALWAYS = 3
    private static let RESULT_AUTHORIZED_WHEN_IN_USE = 4
    
    func toResultValue() -> Int {
        switch self {
        case .notDetermined:
            return CLAuthorizationStatus.RESULT_NOT_DETERMINED
        case .restricted:
            return CLAuthorizationStatus.RESULT_RESTRICTED
        case .denied:
            return CLAuthorizationStatus.RESULT_DENIED
        case .authorizedAlways:
            return CLAuthorizationStatus.RESULT_AUTHORIZED_ALWAYS
        case .authorizedWhenInUse:
            return CLAuthorizationStatus.RESULT_AUTHORIZED_WHEN_IN_USE
        }
    }
}
