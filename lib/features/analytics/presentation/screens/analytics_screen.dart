import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/food_loading_animation.dart';
import 'package:health_app/core/widgets/language_toggle.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/analytics/presentation/providers/weekly_stats_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const double _dailyGoal = 2000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appTranslationsProvider);
    final statsAsync = ref.watch(weeklyStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(weeklyStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr.text('stats_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const LanguageToggle(),
                    ],
                  ),
                ),
              ),
              statsAsync.when(
                loading: () => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FoodLoadingAnimation(size: 140),
                        const SizedBox(height: 12),
                        Text(
                          tr.text('loading_data'),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (_, __) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(tr.text('offline_title'))),
                ),
                data: (stats) {
                  final maxData = stats.points.fold<int>(
                    0,
                    (m, p) => math.max(m, p.calories),
                  );
                  final maxY = math.max(2500.0, (maxData * 1.2).ceilToDouble());

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 3 KPI Summary Cards (Zero Overflow via Expanded + FittedBox)
                        Row(
                          children: [
                            Expanded(
                              child: _KpiTile(
                                label: tr.text('stats_avg'),
                                value: stats.averageCaloriesPerDay
                                    .round()
                                    .toString(),
                                unit: tr.text('kcal'),
                                accent: AppColors.primaryDeep,
                                bg: AppColors.primarySoft,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _KpiTile(
                                label: tr.text('stats_high'),
                                value: '${stats.highestCalories}',
                                unit: tr.text('kcal'),
                                accent: AppColors.butterDeep,
                                bg: AppColors.butterSoft,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _KpiTile(
                                label: tr.text('stats_days'),
                                value: '${stats.totalDaysLogged}/7',
                                unit: tr.text('days_unit'),
                                accent: AppColors.skyDeep,
                                bg: AppColors.skySoft,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Rounded Bar Chart Card
                        SoftCard(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tr.text('stats_chart'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.butterSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tr.text('stats_goal_line'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.butterDeep,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    maxY: maxY,
                                    alignment: BarChartAlignment.spaceAround,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 500,
                                      getDrawingHorizontalLine: (_) =>
                                          const FlLine(
                                        color: AppColors.divider,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    extraLinesData: ExtraLinesData(
                                      horizontalLines: [
                                        HorizontalLine(
                                          y: _dailyGoal,
                                          color: AppColors.butterDeep,
                                          strokeWidth: 1.6,
                                          dashArray: [6, 5],
                                        ),
                                      ],
                                    ),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (_) =>
                                            AppColors.textPrimary,
                                        getTooltipItem: (group, _, rod, __) {
                                          return BarTooltipItem(
                                            '${rod.toY.round()} kcal',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 38,
                                          interval: 1000,
                                          getTitlesWidget: (val, _) {
                                            if (val == 0) {
                                              return const SizedBox.shrink();
                                            }
                                            return Text(
                                              '${(val / 1000).toStringAsFixed(val % 1000 == 0 ? 0 : 1)}k',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textTertiary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (val, _) {
                                            final idx = val.toInt();
                                            if (idx < 0 ||
                                                idx >= stats.points.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final isToday =
                                                idx == stats.points.length - 1;
                                            final wd =
                                                stats.points[idx].date.weekday;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                tr.weekdayShort(wd),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isToday
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                                  color: isToday
                                                      ? AppColors.primaryDeep
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(
                                      stats.points.length,
                                      (i) {
                                        final isToday =
                                            i == stats.points.length - 1;
                                        final y = stats.points[i].calories
                                            .toDouble();
                                        return BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: y,
                                              width: 20,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                              gradient: isToday
                                                  ? AppColors.sunrise
                                                  : AppColors.skyGradient,
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                show: true,
                                                toY: maxY,
                                                color: AppColors.surfaceMuted,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accent;
  final Color bg;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
