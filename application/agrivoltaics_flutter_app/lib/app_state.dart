import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class AppState extends ChangeNotifier {
  AppState() {
    this.timezone = tz.getLocation(AppConstants.timezone);
  }
  
  // Settings
  late tz.Location timezone;
}