import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_location_settings/flutter_location_settings.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_location_settings');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterLocationSettings.platformVersion, '42');
  });
}
