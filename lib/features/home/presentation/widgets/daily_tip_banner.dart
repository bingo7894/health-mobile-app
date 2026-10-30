import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';

/// แบนเนอร์สีเหลืองนวล (Butter Soft) ให้คำแนะนำสุขภาพสั้น ๆ เข้าใจง่ายตามข้อมูลจริงของวันนั้น
class DailyTipBanner extends StatelessWidget {
  final DailySummaryData summary;
  final int dailyGoal;
  final AppTranslations tr;

  const DailyTipBanner({
    super.key,
    required this.summary,
    required this.dailyGoal,
    required this.tr,
  });

  String _pickTipKey() {
    if (summary.totalCaloriesIn == 0) return 'tip_start';
    if (summary.totalCaloriesIn > dailyGoal + summary.totalCaloriesBurned) {
      return 'tip_over';
    }
    if (summary.totalSodiumMg > 1800) return 'tip_sodium';
    if (summary.totalProteinG < 45) return 'tip_protein';
    return 'tip_good';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.butter.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.butter.withAlpha(95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 20,
              color: AppColors.butterDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.text('tip_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.butterDeep,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tr.text(_pickTipKey()),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

