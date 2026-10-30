import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';
import 'package:health_app/features/analytics/presentation/providers/weekly_stats_provider.dart';
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
}
