import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

int _convertPriorityConstant(LocationRequestPriority p) {
  switch (p) {
    // https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_HIGH_ACCURACY
    case LocationRequestPriority.highAccuracy:
      return 100;
    // https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_BALANCED_POWER_ACCURACY
    case LocationRequestPriority.balancedPowerAccuracy:
      return 102;
    // https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_LOW_POWER
    case LocationRequestPriority.lowPower:
      return 104;
    // https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest.html#PRIORITY_NO_POWER
    case LocationRequestPriority.noPower:
      return 105;
    default:
      throw ArgumentError('Unkown $p');
  }
}

class LocationSettingsOptionAndroid {
  final LocationRequestPriority priority;

  final bool alwaysShow;

  final bool needBle;

  final bool showDialogIfNecessary;

  LocationSettingsOptionAndroid({
    @required this.priority,
    this.alwaysShow,
    this.needBle,
    this.showDialogIfNecessary,
  }) : assert(priority != null);

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'priority': _convertPriorityConstant(priority),
      'alwaysShow': alwaysShow,
      'needBle': needBle,
      'showDialog': showDialogIfNecessary
    };
  }
}

class LocationSettingsStatusAndroid {
  static const int SUCCESS = 0;

  final int code;

  bool get isEnabled => this.code == SUCCESS;

  LocationSettingsStatusAndroid(this.code);

  @override
  String toString() {
    return 'LocationSettingsStatusAndroid{code: $code}';
  }
}

class LocationSettingsAndroid {
  static const MethodChannel _channel = const MethodChannel(
      'com.github.droibit.flutter.plugins.flutter_location_settings');

  Future<LocationSettingsStatusAndroid> checkLocationEnabled(
      LocationSettingsOptionAndroid option) async {
    if (!Platform.isAndroid) {
      throw StateError('Supports only Android platform.');
    }

    final int statusCode =
        await _channel.invokeMethod('checkLocationEnabled', option._toMap());

    return LocationSettingsStatusAndroid(statusCode);
  }
}
