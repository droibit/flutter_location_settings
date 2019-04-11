import 'package:flutter/material.dart';
import 'dart:async';

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

  void _checkLocationEnabled() async {
    final status = await LocationSettingsAndroid().checkLocationEnabled(
        LocationSettingsOptionAndroid(
            priority: LocationRequestPriority.highAccuracy,
            alwaysShow: true,
            showDialogIfNecessary: true));
    debugPrint(status.toString());

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _locationStatus =
          'Location enabled: ${status.isEnabled}, code: ${status.code}';
    });
  }
}
