import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum LocationRequestAuthorization { always, whenInUse }

// ignore: missing_return
int _convertAuthorizationConstant(LocationRequestAuthorization authorization) {
  assert(authorization != null);

  switch (authorization) {
    case LocationRequestAuthorization.always:
      return 0;
    case LocationRequestAuthorization.whenInUse:
      return 1;
  }
}

@immutable
class LocationSettingsOptionIOS {
  final LocationRequestAuthorization authorization;

  final bool showDialogIfNecessary;

  LocationSettingsOptionIOS(
      {@required this.authorization, this.showDialogIfNecessary})
      : assert(authorization != null);

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'authorization': _convertAuthorizationConstant(authorization),
      'showDialog': showDialogIfNecessary
    };
  }
}

@immutable
class LocationSettingsStatusIOS {
  static const int RESTRICTED = 1;
  static const int DENIED = 2;
  static const int ENABLED_ALWAYS = 3;
  static const int ENABLED_WHEN_IN_USE = 4;

  final int code;

  bool get isEnabledAlways => code == ENABLED_ALWAYS;

  bool get isEnabledWhenInUse => code == ENABLED_WHEN_IN_USE;

  LocationSettingsStatusIOS(this.code);

  @override
  String toString() {
    return 'LocationSettingsStatusIOS{code: $code}';
  }
}

class LocationSettingsIOS {
  static const MethodChannel _channel = const MethodChannel(
      'com.github.droibit.flutter.plugins.flutter_location_settings');

  Future<LocationSettingsStatusIOS> checkLocationEnabled(
      LocationSettingsOptionIOS option) async {
    if (!Platform.isIOS) {
      throw StateError('Supports only iOS platform.');
    }

    final int code =
        await _channel.invokeMethod('checkLocationEnabled', option._toMap());

    return LocationSettingsStatusIOS(code);
  }
}
