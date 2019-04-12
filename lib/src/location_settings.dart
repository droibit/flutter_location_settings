import 'dart:io';

import 'package:flutter/services.dart';
import 'location_settings_status.dart';

enum LocationRequestPriority {
  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_HIGH_ACCURACY
  highAccuracy,

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_BALANCED_POWER_ACCURACY
  balancedPowerAccuracy,

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_LOW_POWER
  lowPower,

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_NO_POWER
  noPower
}

const _locationRequestPriorityConstants = const <LocationRequestPriority, int>{
  LocationRequestPriority.highAccuracy: 100,
  LocationRequestPriority.balancedPowerAccuracy: 102,
  LocationRequestPriority.lowPower: 104,
  LocationRequestPriority.noPower: 105,
};

class LocationSettings {
  static const MethodChannel _channel = const MethodChannel(
      'com.github.droibit.flutter.plugins.flutter_location_settings');

  Future<LocationSettingsStatus> checkLocationEnabled({
    LocationRequestPriority priority,
    bool alwaysShow,
    bool needBle,
    bool showDialogIfNecessary,
  }) async {
    if (Platform.isAndroid) {
      final int statusCode = await _channel.invokeMethod(
        'checkLocationEnabled',
        _toLocationSettingsOptionMap(
          priority: priority,
          alwaysShow: alwaysShow,
          needBle: needBle,
          showDialogIfNecessary: showDialogIfNecessary,
        ),
      );
      return LocationSettingsStatusAndroid(statusCode);
    } else if (Platform.isIOS) {
      final enabled = await _channel.invokeMethod('checkLocationEnabled');
      return LocationSettingsStatusIOS(enabled);
    }
    throw StateError('Supports only Android or iOS platform.');
  }

  Map<String, dynamic> _toLocationSettingsOptionMap({
    LocationRequestPriority priority,
    bool alwaysShow,
    bool needBle,
    bool showDialogIfNecessary,
  }) {
    final priorityConstant = _locationRequestPriorityConstants[priority];
    if (priority == null) {
      throw ArgumentError('Unkown priority: $priority.');
    }
    return <String, dynamic>{
      'priority': priorityConstant,
      'alwaysShow': alwaysShow,
      'needBle': needBle,
      'showDialog': showDialogIfNecessary
    };
  }
}