import 'package:flutter/foundation.dart';

/// การตั้งค่าการเชื่อมต่อ API Gateway พอร์ต 8080 จุดเดียว
class ApiConfig {
  ApiConfig._();

  /// Default Base URL สำหรับ API Gateway
  /// Android Emulator ใช้ 10.0.2.2, สำหรับ iOS / Web / Desktop ใช้ localhost
  static String get baseUrl {
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

