import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';

/// การ์ดแสดงรายการอาหารของแต่ละมื้อ (เช้า / กลางวัน / เย็น / ของว่าง / มื้อพิเศษ)
/// ใช้ไอคอน 3D Microsoft Fluent Emoji
class MealSectionCard extends StatelessWidget {
  final String mealType;
  final List<MealEntryItem> items;
  final AppTranslations tr;
  final VoidCallback onAddTap;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.items,
    required this.tr,
    required this.onAddTap,
  });

  ({FluentEmojiName emoji, Color bg, Color accent}) _styleForMeal(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return (
          emoji: FluentEmojiName.cooking,
          bg: AppColors.butterSoft,
          accent: AppColors.butterDeep,
        );
      case 'LUNCH':
        return (
          emoji: FluentEmojiName.bento,
          bg: AppColors.primarySoft,
          accent: AppColors.primaryDeep,
        );
      case 'DINNER':
        return (
          emoji: FluentEmojiName.potOfFood,
          bg: AppColors.skySoft,
          accent: AppColors.skyDeep,
        );
      case 'PRE_WORKOUT':
      case 'POST_WORKOUT':
        return (
          emoji: FluentEmojiName.lightning,
          bg: AppColors.mintSoft,
          accent: AppColors.mint,
        );
      default:
        return (
          emoji: FluentEmojiName.apple,
          bg: AppColors.roseSoft,
          accent: AppColors.rose,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleForMeal(mealType);
    final totalKcal = items.fold<int>(0, (sum, e) => sum + e.calories);

    return SoftCard(
      padding: const EdgeInsets.all(16),
      onTap: items.isEmpty ? onAddTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FluentEmoji(style.emoji, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.mealTypeName(mealType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items.isEmpty
                          ? tr.text('meal_empty')
                          : '${tr.itemsCount(items.length)} · $totalKcal ${tr.text('kcal')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            items.isEmpty ? FontWeight.w500 : FontWeight.w600,
                        color: items.isEmpty
                            ? AppColors.textTertiary
                            : style.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primarySoft,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAddTap,
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MealItemRow(item: items[i], tr: tr),
            ],
          ],
        ],
      ),
    );
  }
}

class _MealItemRow extends StatelessWidget {
  final MealEntryItem item;
  final AppTranslations tr;

  const _MealItemRow({required this.item, required this.tr});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.foodName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P ${item.proteinG.toStringAsFixed(0)}g · C ${item.carbsG.toStringAsFixed(0)}g · F ${item.fatG.toStringAsFixed(0)}g',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${item.calories} ${tr.text('kcal')}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeep,
            ),
          ),
        ),
      ],
    );
  }
}
