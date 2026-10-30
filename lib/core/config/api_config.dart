import 'package:flutter/foundation.dart';

/// การตั้งค่าการเชื่อมต่อ API Gateway พอร์ต 8080 จุดเดียว (Single Entry Point)
class ApiConfig {
  ApiConfig._();

  static const String _envUrl = String.fromEnvironment('API_URL');

  /// Default Base URL สำหรับ API Gateway
  /// - รองรับ `--dart-define=API_URL=http://192.168.x.x:8080` สำหรับเครื่องจริงผ่าน Wi-Fi
  /// - Android Emulator ใช้ `10.0.2.2:8080`
  /// - iOS / Web / Desktop (และ USB + `adb reverse`) ใช้ `localhost:8080`
  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  // Endpoints
  static const String nutritionBase = '/api/v1/nutrition';
  static const String aiBase = '/api/v1/ai';
  static const String authBase = '/api/v1/auth';

  // Specific Routes
  static const String meals = '$nutritionBase/meals';
  static const String dailySummary = '$nutritionBase/summary/daily';
  static const String rangeSummary = '$nutritionBase/summary/range';
  static const String monthlySummary = '$nutritionBase/summary/monthly';
  static const String barcode = '$nutritionBase/barcode';
  static const String aiAnalyzeFood = '$aiBase/analyze-food';
}
