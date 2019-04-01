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

// ignore: missing_return
int _convertPriorityConstant(LocationRequestPriority priority) {
  assert(priority != null);

  switch (priority) {
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
  }
}

@immutable
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

@immutable
class LocationSettingsStatusAndroid {

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes.html#SUCCESS
  static const int SUCCESS = 0;

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes.html#CANCELED
  static const int CANCELED = 16;

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationSettingsStatusCodes.html#SETTINGS_CHANGE_UNAVAILABLE
  static const int SETTINGS_CHANGE_UNAVAILABLE = 8502;

  final int code;

  bool get isEnabled => this.code == SUCCESS;

  bool get isDisabled => this.code != SUCCESS;

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
