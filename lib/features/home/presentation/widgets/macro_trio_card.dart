import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';

/// การ์ดแสดงสัดส่วนสารอาหารหลัก 3 ชนิด (โปรตีน = ฟ้า, คาร์บ = เหลือง, ไขมัน = ชมพูพาสเทล)
/// ใช้ไอคอน 3D Microsoft Fluent Emoji สไตล์ Claymorphism
class MacroTrioCard extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final AppTranslations tr;

  const MacroTrioCard({
    super.key,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.tr,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.skySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  size: 18,
                  color: AppColors.skyDeep,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr.text('macros_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MacroBarRow(
            label: tr.text('protein'),
            grams: proteinG,
            targetGrams: 120,
            percentage: proteinPct,
            barColor: AppColors.sky,
            badgeColor: AppColors.skySoft,
            textColor: AppColors.skyDeep,
            emoji: FluentEmojiName.fish,
          ),
          const SizedBox(height: 14),
          _MacroBarRow(
            label: tr.text('carbs'),
            grams: carbsG,
            targetGrams: 225,
            percentage: carbsPct,
            barColor: AppColors.butter,
            badgeColor: AppColors.butterSoft,
            textColor: AppColors.butterDeep,
            emoji: FluentEmojiName.rice,
          ),
          const SizedBox(height: 14),
          _MacroBarRow(
            label: tr.text('fat'),
            grams: fatG,
            targetGrams: 65,
            percentage: fatPct,
            barColor: AppColors.rose,
            badgeColor: AppColors.roseSoft,
            textColor: AppColors.rose,
            emoji: FluentEmojiName.avocado,
          ),
        ],
      ),
    );
  }
}

class _MacroBarRow extends StatelessWidget {
  final String label;
  final double grams;
  final double targetGrams;
  final double percentage;
  final Color barColor;
  final Color badgeColor;
  final Color textColor;
  final FluentEmojiName emoji;

  const _MacroBarRow({
    required this.label,
    required this.grams,
    required this.targetGrams,
    required this.percentage,
    required this.barColor,
    required this.badgeColor,
    required this.textColor,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (grams / targetGrams).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FluentEmoji(emoji, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${grams.toStringAsFixed(0)} / ${targetGrams.toStringAsFixed(0)} g',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: badgeColor,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              );
            },
          ),
        ),
      ],
    );
  }
}
