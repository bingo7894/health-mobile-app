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
      MaterialApp(
        home: Scaffold(
          body: FoodAnalysisResultSheet(
            analysis: FoodAnalysisModel.sample(),
            imageFile: dummyFile,
            tr: AppTranslations(const Locale('th')),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ข้าวกะเพราไก่ไข่ดาว'), findsOneWidget);
    expect(find.text('620 kcal'), findsOneWidget);

    // Scroll down to make action button visible in ListView
    await tester.scrollUntilVisible(
      find.text('ปรับสัดส่วนอาหาร (Smart Portion)'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ปรับสัดส่วนอาหาร (Smart Portion)'), findsOneWidget);
  });

  test('FoodGatekeeper fallback works when file does not exist', () async {
    final result = await FoodGatekeeper.verifyFood('non_existent_file.jpg');
    expect(result.isFood, isTrue);
  });
}
