import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_location_settings/flutter_location_settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _locationStatus = 'Location stauts: Unknown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$_locationStatus'),
              Container(
                margin: EdgeInsets.only(top: 32),
                child: RaisedButton(
                  child: Text('Check Location settings'),
                  onPressed: _checkLocationEnabled,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _checkLocationEnabled() {
    if (Platform.isAndroid) {
      _checkLocationEnabledAndroid();
    } else if (Platform.isIOS) {
      _checkLocationEnabledIOS();
    } else {
      setState(() =>
          {_locationStatus = "Unknown platform: ${Platform.operatingSystem}"});
    }
  }

  void _checkLocationEnabledAndroid() async {
    final status = await LocationSettingsAndroid().checkLocationEnabled(
        LocationSettingsOptionAndroid(
            priority: LocationRequestPriority.highAccuracy,
            alwaysShow: true,
            showDialogIfNecessary: true));
    debugPrint(status.toString());

    if (!mounted) return;

    setState(() {
      _locationStatus =
          'Location enabled: ${status.isEnabled}, code: ${status.code}';
    });
  }

  void _checkLocationEnabledIOS() async {
    final status = await LocationSettingsIOS().checkLocationEnabled(
      LocationSettingsOptionIOS(
        authorization: LocationRequestAuthorization.always,
        showDialogIfNecessary: true
      )
    );

    if (!mounted) return;

    setState(() {
      String text;
      if (status.isEnabledAlways) {
        text = 'always';
      } else if (status.isEnabledWhenInUse) {
        text = 'whenInUse';
      } else {
        text = 'disabled or restrict';
      }
      _locationStatus = 'Location enabled: $text, code: ${status.code}';
    });
  }
}
