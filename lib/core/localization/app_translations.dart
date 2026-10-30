import 'package:flutter/material.dart';

/// พจนานุกรมสองภาษา (ไทย / English)
class AppTranslations {
  final Locale locale;

  AppTranslations(this.locale);

  bool get isThai => locale.languageCode == 'th';

  static const Map<String, Map<String, String>> _values = {
    'th': {
      // General
      'app_title': 'Super Health',
      'app_tagline': 'กินดี อยู่ดี ด้วยผู้ช่วย AI',
      'retry': 'ลองอีกครั้ง',
      'coming_soon': 'ฟีเจอร์นี้กำลังจะมาเร็ว ๆ นี้',
      'offline_title': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้',
      'offline_desc': 'ตรวจสอบว่าเปิด Docker / API Gateway (พอร์ต 8080) อยู่หรือไม่',
      'kcal': 'kcal',
      'g': 'g',

      // Greetings
      'greeting_morning': 'อรุณสวัสดิ์ ☀️',
      'greeting_afternoon': 'สวัสดีตอนบ่าย 🌤️',
      'greeting_evening': 'สวัสดีตอนเย็น 🌙',
      'home_headline': 'วันนี้กินอะไรดี?',

      // Navigation
      'nav_home': 'หน้าหลัก',
      'nav_stats': 'สถิติ',
      'nav_favorites': 'เมนูโปรด',
      'nav_profile': 'ฉัน',

      // Hero calorie card
      'remaining': 'kcal คงเหลือ',
      'over_goal': 'kcal เกินเป้า',
      'eaten': 'กินแล้ว',
      'burned': 'เผาผลาญ',
      'goal': 'เป้าหมาย',

      // Macros
      'macros_title': 'สารอาหารหลัก',
      'protein': 'โปรตีน',
      'carbs': 'คาร์บ',
      'fat': 'ไขมัน',

      // Tips
      'tip_title': 'คำแนะนำวันนี้',
      'tip_start': 'เริ่มบันทึกมื้อแรกของวันได้เลย แค่ถ่ายรูป AI จะคำนวณให้',
      'tip_protein': 'โปรตีนยังน้อยอยู่ ลองเพิ่มไข่ อกไก่ หรือเต้าหู้ในมื้อถัดไป',
      'tip_sodium': 'วันนี้โซเดียมค่อนข้างสูง ดื่มน้ำเปล่าเพิ่ม และลดน้ำจิ้มนะ',
      'tip_over': 'วันนี้แคลอรีเกินเป้าแล้ว มื้อต่อไปลองเน้นผักและโปรตีนไขมันต่ำ',
      'tip_good': 'สมดุลดีมาก! อย่าลืมดื่มน้ำให้ครบ 8 แก้วนะ',

      // Meals
      'meals_title': 'มื้ออาหาร',
      'meal_empty': 'ยังไม่ได้บันทึก แตะ + เพื่อเพิ่ม',
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

      // Scan sheet & Camera
      'scan_title': 'บันทึกอาหาร',
      'scan_subtitle': 'เลือกวิธีที่สะดวกที่สุดสำหรับคุณ',
      'scan_ai_title': 'ถ่ายรูปอาหาร',
      'scan_ai_desc': 'AI ประเมินแคลอรีและสารอาหารให้ทันที',
      'scan_barcode_title': 'สแกนบาร์โค้ด',
      'scan_barcode_desc': 'ขนม เครื่องดื่ม สินค้าร้านสะดวกซื้อ',
      'scan_manual_title': 'พิมพ์เอง',
      'scan_manual_desc': 'ค้นหาหรือกรอกเมนูด้วยตัวเอง',
      'recommended': 'แนะนำ',
      'camera': 'กล้องถ่ายรูป',
      'gallery': 'เลือกจากอัลบั้ม',
      'scan_hint': 'วางจานอาหารหรือเครื่องดื่มให้อยู่ในกรอบ',
      'scan_take_photo': 'ถ่ายรูปเลย',

      // ML Kit Gatekeeper & Compression
      'verifying_food': 'AI ในเครื่องกำลังตรวจสอบอาหาร...',
      'compressing_image': 'กำลังปรับขนาดภาพให้รวดเร็ว...',
      'no_food_detected_title': 'ไม่พบอาหารในภาพ',
      'no_food_detected_desc': 'ระบบตรวจพบว่าเป็น "{label}" กรุณาถ่ายภาพอาหารในจานหรือเครื่องดื่มใหม่อีกครั้งเพื่อความแม่นยำ',
      'retake_photo': 'ถ่ายภาพใหม่',
      'pick_from_gallery': 'เลือกจากอัลบั้ม',

      // User Notes & Photo Review
      'photo_review_title': 'ตรวจสอบรูปภาพ & เพิ่มเติม',
      'add_notes_title': 'รายละเอียดเพิ่มเติม (ถ้ามี)',
      'add_notes_hint': 'เช่น ไข่ดาว 3 ฟอง, หวานน้อย, พิเศษเนื้อ...',
      'send_to_ai': 'ส่งให้ AI วิเคราะห์ ✨',
      'chip_fried_egg_1': '+ ไข่ดาว 1 ฟอง',
      'chip_fried_egg_2': '+ ไข่ดาว 2 ฟอง',
      'chip_fried_egg_3': '+ ไข่ดาว 3 ฟอง',
      'chip_less_rice': 'ข้าวน้อย',
      'chip_less_sweet': 'หวานน้อย',
      'chip_no_oil': 'ไม่ใส่น้ำมัน',
      'chip_extra_meat': 'พิเศษเนื้อ',

      // AI Result
      'ai_result_title': 'ผลการวิเคราะห์อาหาร',
      'ai_confidence': 'ความมั่นใจ AI',
      'estimated_portion': 'น้ำหนักโดยประมาณ',
      'ingredients': 'วัตถุดิบที่ตรวจพบ',
      'cooking_method': 'วิธีปรุง',
      'dietitian_advice': 'คำแนะนำจากนักกำหนดอาหาร',
      'proceed_to_portion': 'ปรับสัดส่วนอาหาร (Smart Portion)',
      'save_directly': 'บันทึกลงมื้ออาหารเลย',
      'save_meal_btn': 'บันทึกมื้ออาหาร',
      'discard_meal_btn': 'ทิ้งรูปนี้ / ถ่ายใหม่',
      'select_meal_category': 'เลือกมื้ออาหารที่จะบันทึก:',
      'confirm_discard_title': 'ทิ้งผลการสแกนนี้?',
      'confirm_discard_desc': 'ข้อมูลโภชนาการนี้จะไม่ถูกบันทึก และจะกลับไปยังหน้ากล้องถ่ายรูป',
      'keep_editing': 'ตรวจสอบต่อ',
      'discard_confirm': 'ยืนยันที่จะทิ้ง',
      'meal_saved_success': 'บันทึกมื้ออาหารสำเร็จ!',
      'meal_save_failed': 'เกิดข้อผิดพลาดในการบันทึก กรุณาลองใหม่อีกครั้ง',

      // Smart Portion
      'smart_portion_title': 'ปรับสัดส่วนอาหาร (Smart Portion)',
      'portion_grams': 'น้ำหนักอาหาร (กรัม)',
      'chip_half_portion': '0.5 จาน (ครึ่งเดียว)',
      'chip_single_portion': '1.0 จาน (ตาม AI)',
      'chip_one_half_portion': '1.5 จาน (อิ่มจุก)',
      'chip_double_portion': '2.0 จาน (พิเศษ 2 เท่า)',
      'save_adjusted_meal': 'บันทึกมื้ออาหารที่ปรับแล้ว',
      'base_ai_estimate': 'สัดส่วนเดิมจาก AI:',
      'macro_breakdown': 'สารอาหารหลังปรับสัดส่วน',
      'grams_unit': 'กรัม',
      'key_ingredients_title': 'วัตถุดิบสำคัญ (ปรับเพิ่ม/ลดกรัมได้)',
      'notes_before_save_title': 'รายละเอียดเพิ่มเติม / โน้ตกำกับ',
      'notes_before_save_hint': 'เช่น ขอข้าวกล้อง, เผลอกินไม่หมดเหลือน้ำมันก้นจาน...',
      'reanalyze_with_note_btn': 'ขอให้ AI คำนวณใหม่ตามโน้ตนี้ ✨',
      'reanalyzing_title': 'AI กำลังวิเคราะห์จานนี้ใหม่ตามโน้ตของคุณ...',

      // Loading
      'loading_data': 'กำลังเตรียมข้อมูลสุขภาพของคุณ...',
      'loading_ai_title': 'AI กำลังดูจานอาหารของคุณ...',
      'loading_ai_desc': 'กำลังนับแคลอรี โปรตีน คาร์บ และไขมัน',
      'loading_barcode_title': 'กำลังค้นหาสินค้า...',
      'loading_barcode_desc': 'ตรวจสอบจากฐานข้อมูลอาหารฟรี',

      // Stats
      'stats_title': 'สถิติ 7 วัน',
      'stats_avg': 'เฉลี่ย/วัน',
      'stats_high': 'สูงสุด',
      'stats_days': 'วันที่บันทึก',
      'stats_chart': 'แคลอรีรายวัน',
      'stats_goal_line': 'เส้นประ = เป้าหมาย',
      'stats_empty': 'ยังไม่มีข้อมูลในสัปดาห์นี้ ลองบันทึกมื้อแรกดูนะ',
      'days_unit': 'วัน',

      // Favorites
      'fav_title': 'เมนูโปรด',
      'fav_empty_title': 'ยังไม่มีเมนูโปรด',
      'fav_empty_desc': 'เก็บมื้อที่กินบ่อยไว้ที่นี่ แล้วบันทึกได้ในแตะเดียว',
      'fav_cta': 'สแกนอาหารเลย',

      // Profile
      'profile_title': 'โปรไฟล์ของฉัน',
      'profile_name': 'ผู้ใช้ทดลอง',
      'profile_goal_tag': 'เป้าหมาย: รักษาน้ำหนัก',
      'bmr': 'BMR',
      'tdee': 'TDEE',
      'daily_goal': 'เป้าหมาย/วัน',
      'settings': 'การตั้งค่า',
      'language': 'ภาษา',
      'notifications': 'การแจ้งเตือน',
      'about': 'เกี่ยวกับแอป',
      'version': 'เวอร์ชัน 1.0.0',
    },
    'en': {
      // General
      'app_title': 'Super Health',
      'app_tagline': 'Eat well, live well with AI',
      'retry': 'Try again',
      'coming_soon': 'This feature is coming soon',
      'offline_title': "Can't reach the server",
      'offline_desc': 'Make sure Docker / API Gateway (port 8080) is running',
      'kcal': 'kcal',
      'g': 'g',

      // Greetings
      'greeting_morning': 'Good morning ☀️',
      'greeting_afternoon': 'Good afternoon 🌤️',
      'greeting_evening': 'Good evening 🌙',
      'home_headline': 'Ready to eat well?',

      // Navigation
      'nav_home': 'Home',
      'nav_stats': 'Stats',
      'nav_favorites': 'Favorites',
      'nav_profile': 'Me',

      // Hero calorie card
      'remaining': 'kcal left',
      'over_goal': 'kcal over',
      'eaten': 'Eaten',
      'burned': 'Burned',
      'goal': 'Goal',

      // Macros
      'macros_title': 'Macronutrients',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',

      // Tips
      'tip_title': "Today's tip",
      'tip_start': 'Log your first meal — just snap a photo and AI does the math',
      'tip_protein': 'Protein is low. Try adding eggs, chicken breast or tofu next meal',
      'tip_sodium': 'Sodium is high today. Drink more water and go easy on sauces',
      'tip_over': "You're over today's goal. Go for veggies and lean protein next",
      'tip_good': 'Nicely balanced! Remember to drink 8 glasses of water',

      // Meals
      'meals_title': 'Meals',
      'meal_empty': 'Not logged yet — tap + to add',
      'meal_breakfast': 'Breakfast',
      'meal_brunch': 'Brunch',
      'meal_lunch': 'Lunch',
      'meal_afternoon_tea': 'Afternoon tea',
      'meal_dinner': 'Dinner',
      'meal_pre_workout': 'Pre-workout',
      'meal_post_workout': 'Post-workout',
      'meal_snack': 'Snack',
      'meal_supper': 'Supper',
      'meal_supplement': 'Supplement',

      // Scan sheet & Camera
      'scan_title': 'Log your food',
      'scan_subtitle': 'Pick the easiest way for you',
      'scan_ai_title': 'Snap a photo',
      'scan_ai_desc': 'AI estimates calories & nutrients instantly',
      'scan_barcode_title': 'Scan barcode',
      'scan_barcode_desc': 'Snacks, drinks & packaged food',
      'scan_manual_title': 'Type it in',
      'scan_manual_desc': 'Search or enter a meal yourself',
      'recommended': 'Best',
      'camera': 'Camera',
      'gallery': 'From Gallery',
      'scan_hint': 'Fit your meal or drink inside the frame',
      'scan_take_photo': 'Take photo',

      // ML Kit Gatekeeper & Compression
      'verifying_food': 'On-device AI is verifying food...',
      'compressing_image': 'Optimizing image size...',
      'no_food_detected_title': 'No Food Detected',
      'no_food_detected_desc': 'Detected as "{label}". Please snap a photo of a meal or drink for accurate results.',
      'retake_photo': 'Take new photo',
      'pick_from_gallery': 'Pick from gallery',

      // User Notes & Photo Review
      'photo_review_title': 'Review Photo & Notes',
      'add_notes_title': 'Add specific details (optional)',
      'add_notes_hint': 'e.g., 3 fried eggs, less sweet, extra meat...',
      'send_to_ai': 'Analyze with AI ✨',
      'chip_fried_egg_1': '+ 1 fried egg',
      'chip_fried_egg_2': '+ 2 fried eggs',
      'chip_fried_egg_3': '+ 3 fried eggs',
      'chip_less_rice': 'Less rice',
      'chip_less_sweet': 'Less sweet',
      'chip_no_oil': 'No added oil',
      'chip_extra_meat': 'Extra meat',

      // AI Result
      'ai_result_title': 'Nutrition Analysis',
      'ai_confidence': 'AI Confidence',
      'estimated_portion': 'Estimated weight',
      'ingredients': 'Detected ingredients',
      'cooking_method': 'Cooking method',
      'dietitian_advice': 'Dietitian advice',
      'proceed_to_portion': 'Adjust portion (Smart Portion)',
      'save_directly': 'Save meal directly',
      'save_meal_btn': 'Save Meal',
      'discard_meal_btn': 'Discard / Retake photo',
      'select_meal_category': 'Select meal category:',
      'confirm_discard_title': 'Discard this scan?',
      'confirm_discard_desc': 'This nutrition data will not be saved and you will return to the camera.',
      'keep_editing': 'Keep reviewing',
      'discard_confirm': 'Discard',
      'meal_saved_success': 'Meal saved successfully!',
      'meal_save_failed': 'Failed to save meal. Please try again.',

      // Smart Portion
      'smart_portion_title': 'Smart Portion Adjustment',
      'portion_grams': 'Portion Weight (grams)',
      'chip_half_portion': '0.5 plate (half)',
      'chip_single_portion': '1.0 plate (regular)',
      'chip_one_half_portion': '1.5 plate (large)',
      'chip_double_portion': '2.0 plate (double)',
      'save_adjusted_meal': 'Save Adjusted Meal',
      'base_ai_estimate': 'Original AI estimate:',
      'macro_breakdown': 'Nutrients After Adjustment',
      'grams_unit': 'g',
      'key_ingredients_title': 'Key Ingredients (Adjust Grams)',
      'notes_before_save_title': 'Additional Notes & Specifics',
      'notes_before_save_hint': 'e.g., brown rice instead, left half of oil on plate...',
      'reanalyze_with_note_btn': 'Re-analyze with this note ✨',
      'reanalyzing_title': 'AI is re-analyzing with your note...',

      // Loading
      'loading_data': 'Preparing your health data...',
      'loading_ai_title': 'AI is looking at your plate...',
      'loading_ai_desc': 'Counting calories, protein, carbs & fat',
      'loading_barcode_title': 'Looking up product...',
      'loading_barcode_desc': 'Checking the free food database',

      // Stats
      'stats_title': 'Last 7 days',
      'stats_avg': 'Avg / day',
      'stats_high': 'Highest',
      'stats_days': 'Days logged',
      'stats_chart': 'Daily calories',
      'stats_goal_line': 'Dashed line = goal',
      'stats_empty': 'No data this week yet. Log your first meal!',
      'days_unit': 'days',

      // Favorites
      'fav_title': 'Favorites',
      'fav_empty_title': 'No favorites yet',
      'fav_empty_desc': 'Save meals you eat often and log them in one tap',
      'fav_cta': 'Scan a meal',

      // Profile
      'profile_title': 'My profile',
      'profile_name': 'Demo user',
      'profile_goal_tag': 'Goal: maintain weight',
      'bmr': 'BMR',
      'tdee': 'TDEE',
      'daily_goal': 'Daily goal',
      'settings': 'Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'about': 'About',
      'version': 'Version 1.0.0',
    },
  };

  static const _weekdaysTh = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysLongTh = ['วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี', 'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์'];
  static const _weekdaysLongEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _monthsTh = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
  static const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['th']?[key] ?? key;

  String itemsCount(int n) => isThai ? '$n รายการ' : '$n ${n == 1 ? 'item' : 'items'}';

  String weekdayShort(int weekday) => (isThai ? _weekdaysTh : _weekdaysEn)[weekday - 1];

  /// เช่น "วันพฤหัสบดี 30 ต.ค." / "Thursday, 30 Oct"
  String longDate(DateTime d) {
    final day = (isThai ? _weekdaysLongTh : _weekdaysLongEn)[d.weekday - 1];
    final month = (isThai ? _monthsTh : _monthsEn)[d.month - 1];
    return isThai ? '$day ${d.day} $month' : '$day, ${d.day} $month';
  }

  String greeting(DateTime now) {
    if (now.hour < 12) return text('greeting_morning');
    if (now.hour < 17) return text('greeting_afternoon');
    return text('greeting_evening');
  }

  String mealTypeName(String mealType) {
    final key = 'meal_${mealType.toLowerCase()}';
    final value = text(key);
    return value == key ? mealType : value;
  }
}
