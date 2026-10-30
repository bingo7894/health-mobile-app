import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/food_loading_animation.dart';
import 'package:health_app/core/widgets/language_toggle.dart';
import 'package:health_app/features/food_scanner/presentation/screens/scan_options_sheet.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';
import 'package:health_app/features/home/presentation/widgets/calorie_hero_card.dart';
import 'package:health_app/features/home/presentation/widgets/daily_tip_banner.dart';
import 'package:health_app/features/home/presentation/widgets/macro_trio_card.dart';
import 'package:health_app/features/home/presentation/widgets/meal_section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _dailyCalorieGoal = 2000;
  static const List<String> _standardMealOrder = [
    'BREAKFAST',
    'LUNCH',
    'DINNER',
    'SNACK',
  ];

  List<String> _orderedMealTypes(Map<String, List<MealEntryItem>> map) {
    final result = <String>[..._standardMealOrder];
    for (final key in map.keys) {
      final upper = key.toUpperCase();
      if (!result.contains(upper)) {
        result.add(key);
      }
    }
    return result;
  }

  List<MealEntryItem> _itemsFor(
    Map<String, List<MealEntryItem>> map,
    String targetType,
  ) {
    for (final entry in map.entries) {
      if (entry.key.toUpperCase() == targetType.toUpperCase()) {
        return entry.value;
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appTranslationsProvider);
    final summaryAsync = ref.watch(dailySummaryProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.refresh(dailySummaryProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Top Greeting Header + Language Switcher (Guaranteed Zero Overflow)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tr.greeting(now)} · ${tr.longDate(now)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr.text('home_headline'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const LanguageToggle(),
                    ],
                  ),
                ),
              ),

              // Main Content Body
              summaryAsync.when(
                loading: () => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FoodLoadingAnimation(
                            size: 160,
                            lottieAsset: 'assets/animations/food_loading.json',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr.text('loading_data'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const BouncingDots(),
                        ],
                      ),
                    ),
                  ),
                ),
                error: (_, __) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 52,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tr.text('offline_title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr.text('offline_desc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(dailySummaryProvider),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(tr.text('retry')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (summary) {
                  final mealTypes = _orderedMealTypes(summary.mealsByMealType);

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        CalorieHeroCard(
                          dailyGoal: _dailyCalorieGoal,
                          eaten: summary.totalCaloriesIn,
                          burned: summary.totalCaloriesBurned,
                          tr: tr,
                        ),
                        const SizedBox(height: 14),
                        DailyTipBanner(
                          summary: summary,
                          dailyGoal: _dailyCalorieGoal,
                          tr: tr,
                        ),
                        const SizedBox(height: 14),
                        MacroTrioCard(
                          proteinG: summary.totalProteinG,
                          carbsG: summary.totalCarbsG,
                          fatG: summary.totalFatG,
                          proteinPct: summary.proteinPercentage,
                          carbsPct: summary.carbsPercentage,
                          fatPct: summary.fatPercentage,
                          tr: tr,
                        ),
                        const SizedBox(height: 22),

                        // Section header: Meals + clean count badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tr.text('meals_title'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.skySoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                tr.itemsCount(summary.totalMealsCount),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.skyDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        for (var i = 0; i < mealTypes.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          MealSectionCard(
                            mealType: mealTypes[i],
                            items: _itemsFor(
                              summary.mealsByMealType,
                              mealTypes[i],
                            ),
                            tr: tr,
                            onAddTap: () => ScanOptionsSheet.show(
                              context,
                              mealType: mealTypes[i],
                            ),
                          ),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
