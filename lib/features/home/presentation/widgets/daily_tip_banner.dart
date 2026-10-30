import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';

/// แบนเนอร์คำแนะนำสุขภาพ สไตล์ Soft 3D Claymorphism
/// พระอาทิตย์ 3D ขนาด 32dp บนแท่นนูน 46dp
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9E8), Color(0xFFFFECC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AD9971A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Sun token (46x46dp with white bevel)
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(210),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20D9971A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const FluentEmoji(FluentEmojiName.sun, size: 32),
          ),
          const SizedBox(width: 14),
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
                    fontWeight: FontWeight.w600,
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
