import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  Map<String, dynamic> _config = {};
  static const String CONFIG_PATH = 'assets/config/app_settings.json';

  Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(CONFIG_PATH);
      _config = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("Error loading app_settings.json");
    }
  }

  String getServerUrl() {
    return _config['api_settings']?['server_url'] ?? "";
  }
}
