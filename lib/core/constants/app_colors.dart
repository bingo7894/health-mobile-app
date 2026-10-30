import 'package:flutter/material.dart';

/// "Soft Sunrise" palette — ส้ม / ฟ้า / เหลือง โทนพาสเทลอุ่น ๆ สบายตา ไม่แสบตา
/// พื้นหลังเป็นครีมอุ่น (ไม่ใช่ขาวจ้า) และตัวอักษรเป็นกรมท่าเข้ม (ไม่ใช่ดำสนิท)
class AppColors {
  AppColors._();

  // Brand — ส้ม (พลังงาน / แคลอรี / ปุ่มหลัก)
  static const Color primary = Color(0xFFFF8A4C);
  static const Color primaryDeep = Color(0xFFEE6F33);
  static const Color primarySoft = Color(0xFFFFE9DC);

  // ฟ้า (สุขภาพ / โปรตีน / ความสงบ)
  static const Color sky = Color(0xFF4FB3E8);
  static const Color skyDeep = Color(0xFF2A8BC2);
  static const Color skySoft = Color(0xFFE3F3FC);

  // เหลือง (สดใส / คาร์บ / คำแนะนำ)
  static const Color butter = Color(0xFFFFC94D);
  static const Color butterDeep = Color(0xFFD9971A);
  static const Color butterSoft = Color(0xFFFFF4D6);

  // สีเสริม
  static const Color rose = Color(0xFFF58FA8); // ไขมัน
  static const Color roseSoft = Color(0xFFFDE8EE);
  static const Color mint = Color(0xFF4CC9A0); // ออกกำลังกาย
  static const Color mintSoft = Color(0xFFE0F7EF);

  // Neutrals
  static const Color background = Color(0xFFFFFAF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFFF3E8);
  static const Color textPrimary = Color(0xFF2B2D42);
  static const Color textSecondary = Color(0xFF6B7083);
  static const Color textTertiary = Color(0xFFA6AABA);
  static const Color border = Color(0xFFF2E9DF);
  static const Color divider = Color(0xFFF5EEE6);
  static const Color shadow = Color(0x1AB4783C); // เงาโทนอุ่น ไม่ใช่เงาเทา

  // Feedback
  static const Color error = Color(0xFFE5675C);
  static const Color errorSoft = Color(0xFFFDECEA);

  // Gradients
  static const LinearGradient sunrise = LinearGradient(
    colors: [Color(0xFFFF8A4C), Color(0xFFFFB067)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF4FB3E8), Color(0xFF86D3F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];
}
