import 'package:flutter/material.dart';

/// คลาสพจนานุกรมคำแปลสองภาษา (Thai & English)
class AppTranslations {
  final Locale locale;

  AppTranslations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'th': {
      // App General
      'app_title': 'ซูเปอร์แอปสุขภาพ',
      'app_subtitle': 'AI โภชนาการ & ผู้ช่วยสุขภาพอัจฉริยะ',
      'loading': 'กำลังโหลดข้อมูล...',
      'error_occurred': 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
      'retry': 'ลองอีกครั้ง',
      'save': 'บันทึก',
      'cancel': 'ยกเลิก',
      'confirm': 'ยืนยัน',
      'delete': 'ลบ',
      'edit': 'แก้ไข',

      // Navigation
      'nav_home': 'ไดอารี่',
      'nav_scan': 'สแกน',
      'nav_analytics': 'สถิติ',
      'nav_profile': 'โปรไฟล์',

      // Home & Diary
      'today': 'วันนี้',
      'daily_summary': 'สรุปโภชนาการวันนี้',
      'remaining': 'คงเหลือ',
      'consumed': 'กินไปแล้ว',
      'burned': 'เผาผลาญ',
      'target': 'เป้าหมาย',
      'kcal': 'กิโลแคลอรี',
      'grams': 'กรัม',
      'milligrams': 'มก.',

      // Macronutrients
      'protein': 'โปรตีน',
      'carbs': 'คาร์บ',
      'fat': 'ไขมัน',
      'sodium': 'โซเดียม',
      'sugar': 'น้ำตาล',
      'fiber': 'ใยอาหาร',
      'macro_distribution': 'สัดส่วนพลังงาน (Macro %)',

      // Meals
      'meals_today': 'มื้ออาหารวันนี้',
      'add_meal': '+ บันทึกมื้อนี้',
      'meal_breakfast': 'มื้อเช้า',
      'meal_brunch': 'มื้อสาย',
      'meal_lunch': 'มื้อกลางวัน',
      'meal_afternoon_tea': 'ของว่างบ่าย',
      'meal_dinner': 'มื้อเย็น',
      'meal_pre_workout': 'ก่อนออกกำลังกาย',
      'meal_post_workout': 'หลังออกกำลังกาย',
      'meal_snack': 'ของว่าง',
      'meal_supper': 'มื้อดึก',
      'meal_supplement': 'อาหารเสริม',
      'no_meals_logged': 'ยังไม่มีรายการอาหารในมื้อนี้',

      // Scanner Sheet
      'scan_title': 'บันทึกอาหารด้วย AI & บาร์โค้ด',
      'scan_camera_title': 'ถ่ายรูปอาหาร (AI Vision Scan)',
      'scan_camera_desc': 'ประเมินแคลอรี สารอาหาร และวัตถุดิบอัตโนมัติ',
      'scan_barcode_title': 'สแกนบาร์โค้ดสินค้า (Free Scan)',
      'scan_barcode_desc': 'ดึงข้อมูลสินค้าสะดวกซื้อ ขนม และเครื่องดื่มทันที',
      'scan_manual_title': 'กรอกรายการด้วยตนเอง',
      'scan_manual_desc': 'พิมพ์ชื่อและปริมาณอาหารด้วยตัวเอง',

      // AI Loading
      'ai_analyzing_title': 'AI กำลังวิเคราะห์จานอาหารของคุณ...',
      'ai_analyzing_desc': 'กำลังประเมินแคลอรี โปรตีน คาร์บ ไขมัน และวัตถุดิบ',

      // Analytics
      'analytics_title': 'สถิติและแนวโน้มสุขภาพ',
      'weekly_trend': 'แนวโน้มแคลอรี 7 วันล่าสุด',
      'daily_average': 'ค่าเฉลี่ยต่อวัน',
      'highest_day': 'วันที่กินสูงสุด',
      'lowest_day': 'วันที่กินต่ำสุด',
      'days_logged': 'วันที่บันทึกสำเร็จ',

      // Profile & Settings
      'profile_title': 'โปรไฟล์และเป้าหมายสุขภาพ',
      'language_setting': 'ภาษา (Language)',
      'language_thai': 'ภาษาไทย (TH)',
      'language_english': 'English (EN)',
      'bmr_tdee_title': 'ค่าการเผาผลาญส่วนบุคคล',
      'bmr': 'BMR (เผาผลาญพื้นฐาน)',
      'tdee': 'TDEE (เผาผลาญรวมต่อวัน)',
      'daily_goal': 'เป้าหมายแคลอรีต่อวัน',
      'version': 'เวอร์ชัน 1.0.0 (Enterprise Microservices)',
    },
    'en': {
      // App General
      'app_title': 'Super Health App',
      'app_subtitle': 'AI Nutrition & Smart Wellness Assistant',
      'loading': 'Loading data...',
      'error_occurred': 'An error occurred. Please try again.',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',

      // Navigation
      'nav_home': 'Diary',
      'nav_scan': 'Scan',
      'nav_analytics': 'Analytics',
      'nav_profile': 'Profile',

      // Home & Diary
      'today': 'Today',
      'daily_summary': "Today's Nutrition Summary",
      'remaining': 'Remaining',
      'consumed': 'Consumed',
      'burned': 'Burned',
      'target': 'Daily Goal',
      'kcal': 'kcal',
      'grams': 'g',
      'milligrams': 'mg',

      // Macronutrients
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',
      'sodium': 'Sodium',
      'sugar': 'Sugar',
      'fiber': 'Fiber',
      'macro_distribution': 'Energy Ratio (Macro %)',

      // Meals
      'meals_today': "Today's Meals",
      'add_meal': '+ Log This Meal',
      'meal_breakfast': 'Breakfast',
      'meal_brunch': 'Brunch',
      'meal_lunch': 'Lunch',
      'meal_afternoon_tea': 'Afternoon Tea',
      'meal_dinner': 'Dinner',
      'meal_pre_workout': 'Pre-Workout',
      'meal_post_workout': 'Post-Workout',
      'meal_snack': 'Snack',
      'meal_supper': 'Supper',
      'meal_supplement': 'Supplement',
      'no_meals_logged': 'No meals logged yet in this section',

      // Scanner Sheet
      'scan_title': 'Food Logging with AI & Barcode',
      'scan_camera_title': 'AI Food Photo Scan',
      'scan_camera_desc': 'Instantly estimate calories, macros & ingredients',
      'scan_barcode_title': 'Free Barcode Scan',
      'scan_barcode_desc': 'Lookup convenience foods, snacks & beverages',
      'scan_manual_title': 'Manual Food Entry',
      'scan_manual_desc': 'Type food name and nutrition manually',

      // AI Loading
      'ai_analyzing_title': 'AI is analyzing your meal plate...',
      'ai_analyzing_desc': 'Estimating calories, protein, carbs, fat & ingredients',

      // Analytics
      'analytics_title': 'Health Statistics & Trends',
      'weekly_trend': 'Last 7 Days Calorie Trend',
      'daily_average': 'Daily Average',
      'highest_day': 'Highest Calorie Day',
      'lowest_day': 'Lowest Calorie Day',
      'days_logged': 'Days Logged',

      // Profile & Settings
      'profile_title': 'Profile & Health Goals',
      'language_setting': 'Language',
      'language_thai': 'ภาษาไทย (TH)',
      'language_english': 'English (EN)',
      'bmr_tdee_title': 'Personal Energy Expenditure',
      'bmr': 'BMR (Basal Metabolic Rate)',
      'tdee': 'TDEE (Total Daily Energy)',
      'daily_goal': 'Daily Calorie Target',
      'version': 'Version 1.0.0 (Enterprise Microservices)',
    },
  };

  String text(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['th']?[key] ?? key;
  }

  String mealTypeName(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return text('meal_breakfast');
      case 'BRUNCH':
        return text('meal_brunch');
      case 'LUNCH':
        return text('meal_lunch');
      case 'AFTERNOON_TEA':
        return text('meal_afternoon_tea');
      case 'DINNER':
        return text('meal_dinner');
      case 'PRE_WORKOUT':
        return text('meal_pre_workout');
      case 'POST_WORKOUT':
        return text('meal_post_workout');
      case 'SNACK':
        return text('meal_snack');
      case 'SUPPER':
        return text('meal_supper');
      case 'SUPPLEMENT':
        return text('meal_supplement');
      default:
        return mealType;
    }
  }
}

