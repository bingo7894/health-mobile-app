import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:health_app/features/food_scanner/presentation/screens/scan_options_sheet.dart';
import '../providers/daily_summary_provider.dart';
import '../widgets/calorie_budget_card.dart';
import '../widgets/macro_progress_bar.dart';
import '../widgets/meal_timeline_card.dart';

/// หน้าหลักของสมุดบันทึกอาหารและโภชนาการประจำวัน (Home / Food Diary)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final summaryAsync = ref.watch(dailySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orangePrimary,
          onRefresh: () async {
            ref.invalidate(dailySummaryProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Greeting & Language Switcher Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.text('today'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orangePrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr.text('app_title'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // 1-Tap Language Toggle Button (TH | EN)
                      const LanguageSwitcherButton(),
                    ],
                  ),
                ),
              ),

              // Summary Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: summaryAsync.when(
                  loading: () => SliverList(
                    delegate: SliverChildListDelegate([
                      const ShimmerLoading(width: double.infinity, height: 180, borderRadius: 24),
                      const SizedBox(height: 16),
                      const ShimmerLoading(width: double.infinity, height: 120, borderRadius: 24),
                      const SizedBox(height: 16),
                      const ShimmerLoading(width: double.infinity, height: 80, borderRadius: 20),
                    ]),
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            tr.text('error_occurred'),
                            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(dailySummaryProvider),
                            child: Text(tr.text('retry')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (data) {
                    final mealsMap = data.mealsByMealType;
                    const standardMealTypes = ['BREAKFAST', 'LUNCH', 'PRE_WORKOUT', 'DINNER', 'SNACK'];

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Calorie Budget Ring & Details
                        CalorieBudgetCard(
                          consumedCalories: data.totalCaloriesIn,
                          targetCalories: 2000,
                          burnedCalories: data.totalCaloriesBurned,
                        ),
                        const SizedBox(height: 16),

                        // 2. Macro Nutrients Ratio (Carbs / Protein / Fat)
                        MacroProgressBar(
                          proteinG: data.totalProteinG,
                          carbsG: data.totalCarbsG,
                          fatG: data.totalFatG,
                          proteinPct: data.proteinPercentage,
                          carbsPct: data.carbsPercentage,
                          fatPct: data.fatPercentage,
                        ),
                        const SizedBox(height: 24),

                        // 3. Section Title: Today's Meals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr.text('meals_today'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.blueLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${data.totalMealsCount} ${tr.text('nav_home')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 4. Meal Cards Timeline
                        ...standardMealTypes.map((type) {
                          final items = (mealsMap[type] as List<dynamic>?) ?? [];
                          return MealTimelineCard(
                            mealType: type,
                            items: items,
                            onAddMeal: () {
                              ScanOptionsSheet.show(context);
                            },
                          );
                        }),

                        const SizedBox(height: 80), // Bottom padding for FAB
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

