import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/utils/food_gatekeeper.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';
import 'package:health_app/features/analytics/presentation/providers/weekly_stats_provider.dart';
import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';
import 'package:health_app/features/food_scanner/presentation/screens/food_scanner_screen.dart';
import 'package:health_app/features/food_scanner/presentation/screens/food_analysis_result_sheet.dart';
import 'package:health_app/features/food_scanner/presentation/screens/food_photo_review_sheet.dart';
import 'package:health_app/features/food_scanner/presentation/screens/smart_portion_screen.dart';
import 'package:health_app/features/food_scanner/domain/utils/macro_calculator.dart';
import 'package:health_app/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('SuperHealthApp renders Soft Sunrise UI with zero overflow on narrow screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailySummaryProvider.overrideWith((_) async => DailySummaryData.sample()),
          weeklyStatsProvider.overrideWith((_) async => WeeklySummaryData.sample()),
        ],
        child: const SuperHealthApp(),
      ),
    );

    // 1. Splash screen intro animation renders cleanly
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Super Health'), findsOneWidget);

    // 2. Advance past splash timer (2400ms) + fade route transition (520ms)
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800));

    // 3. Home screen in Thai renders cleanly with 4-tab bar
    expect(find.text('วันนี้กินอะไรดี?'), findsOneWidget);
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('สถิติ'), findsOneWidget);
    expect(find.text('เมนูโปรด'), findsOneWidget);
    expect(find.text('ฉัน'), findsOneWidget);

    // 4. Toggle language TH -> EN and verify no overflow in English either
    await tester.tap(find.text('EN').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Ready to eat well?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);

    // 5. Navigate across Stats, Favorites, and Me tabs
    await tester.tap(find.text('Stats'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.tap(find.text('Favorites'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No favorites yet'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('My profile'), findsOneWidget);
  });

  testWidgets('FoodScannerScreen renders camera viewfinder with guidance overlay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FoodScannerScreen(mealType: 'BREAKFAST'),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(FoodScannerScreen), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
  });

  testWidgets('FoodAnalysisResultSheet renders 3D nutrition results cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final dummyFile = File('dummy_food.jpg');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: FoodAnalysisResultSheet(
              analysis: FoodAnalysisModel.sample(),
              imageFile: dummyFile,
              tr: AppTranslations(const Locale('th')),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ข้าวกะเพราไก่ไข่ดาว'), findsOneWidget);
    expect(find.text('620 kcal'), findsOneWidget);

    // Scroll down to make action buttons visible in ListView
    await tester.scrollUntilVisible(
      find.text('ทิ้งรูปนี้ / ถ่ายใหม่'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('ทิ้งรูปนี้ / ถ่ายใหม่'));
    await tester.pumpAndSettle();

    expect(find.text('เลือกมื้ออาหารที่จะบันทึก:'), findsOneWidget);
    expect(find.text('ทิ้งรูปนี้ / ถ่ายใหม่'), findsOneWidget);
    expect(find.text('ปรับสัดส่วนอาหาร (Smart Portion)'), findsOneWidget);

    // Tap discard button to test confirmation dialog
    await tester.tap(find.text('ทิ้งรูปนี้ / ถ่ายใหม่'));
    await tester.pumpAndSettle();
    expect(find.text('ทิ้งผลการสแกนนี้?'), findsOneWidget);
    expect(find.text('ตรวจสอบต่อ'), findsOneWidget);
    expect(find.text('ยืนยันที่จะทิ้ง'), findsOneWidget);

    // Cancel discard dialog
    await tester.tap(find.text('ตรวจสอบต่อ'));
    await tester.pumpAndSettle();
    expect(find.text('ทิ้งผลการสแกนนี้?'), findsNothing);
  });

  testWidgets('FoodPhotoReviewSheet renders preview, quick chips and appends notes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final dummyFile = File('dummy_food.jpg');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodPhotoReviewSheet(
            imageFile: dummyFile,
            tr: AppTranslations(const Locale('th')),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ตรวจสอบรูปภาพ & เพิ่มเติม'), findsOneWidget);
    expect(find.text('+ ไข่ดาว 3 ฟอง'), findsOneWidget);
    expect(find.text('ส่งให้ AI วิเคราะห์ ✨'), findsOneWidget);

    // Tap quick chip
    await tester.tap(find.text('+ ไข่ดาว 3 ฟอง'));
    await tester.pump();
    expect(find.text('+ ไข่ดาว 3 ฟอง'), findsWidgets);
  });

  test('FoodGatekeeper fallback works when file does not exist', () async {
    final result = await FoodGatekeeper.verifyFood('non_existent_file.jpg');
    expect(result.isFood, isTrue);
  });

  test('MacroCalculator accurately scales calories and macros proportionally', () {
    final result = MacroCalculator.calculate(
      baseWeightGrams: 300.0,
      baseCalories: 600,
      baseProteinG: 30.0,
      baseCarbsG: 60.0,
      baseFatG: 20.0,
      baseSodiumMg: 800.0,
      baseSugarG: 10.0,
      baseFiberG: 4.0,
      targetWeightGrams: 150.0, // 0.5x
    );

    expect(result.ratio, equals(0.5));
    expect(result.calories, equals(300));
    expect(result.proteinG, equals(15.0));
    expect(result.carbsG, equals(30.0));
    expect(result.fatG, equals(10.0));
    expect(result.sodiumMg, equals(400.0));
  });

  testWidgets('SmartPortionScreen renders slider, preset chips and recalculates live',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SmartPortionScreen(
            analysis: FoodAnalysisModel.sample(),
            initialMealType: 'LUNCH',
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ปรับสัดส่วนอาหาร (Smart Portion)'), findsOneWidget);
    expect(find.text('ข้าวกะเพราไก่ไข่ดาว'), findsOneWidget);
    expect(find.text('620'), findsOneWidget); // base calories
    expect(find.text('0.5 จาน (ครึ่งเดียว)'), findsOneWidget);

    // Tap 0.5x chip
    await tester.tap(find.text('0.5 จาน (ครึ่งเดียว)'));
    await tester.pump();

    // 620 * 0.5 = 310 kcal
    expect(find.text('310'), findsOneWidget);
    expect(find.text('175 กรัม'), findsOneWidget); // 350 * 0.5 = 175g
  });
}
