import 'dart:async';

import 'package:flutter/services.dart';

class FlutterLocationSettings {
  static const MethodChannel _channel =
      const MethodChannel('flutter_location_settings');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
