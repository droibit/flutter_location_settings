import 'package:flutter/foundation.dart';

abstract class LocationSettingsStatus {
  bool get isEnabled;
  bool get isDisabled;
}

@immutable
class LocationSettingsStatusAndroid implements LocationSettingsStatus {

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes.html#SUCCESS
  static const int SUCCESS = 0;

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes.html#CANCELED
  static const int CANCELED = 16;

  /// ref. https://developers.google.com/android/reference/com/google/android/gms/location/LocationSettingsStatusCodes.html#SETTINGS_CHANGE_UNAVAILABLE
  static const int SETTINGS_CHANGE_UNAVAILABLE = 8502;

  final int code;

  @override
  bool get isEnabled => this.code == SUCCESS;

  @override
  bool get isDisabled => this.code != SUCCESS;

  LocationSettingsStatusAndroid(this.code);

  @override
  String toString() {
    return 'LocationSettingsStatusAndroid{code: $code}';
  }
}

@immutable
class LocationSettingsStatusIOS implements LocationSettingsStatus {

  final bool _enabled;

  @override
  bool get isEnabled => _enabled;

  @override
  bool get isDisabled => !_enabled;

  LocationSettingsStatusIOS(this._enabled);

  @override
  String toString() {
    return 'LocationSettingsStatusIOS{enabled: $_enabled}';
  }
}