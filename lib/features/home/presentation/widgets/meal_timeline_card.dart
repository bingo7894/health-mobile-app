import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';

/// การ์ดแสดงรายการมื้ออาหารของวันนั้น (Breakfast, Lunch, Pre-Workout, Dinner, etc.)
class MealTimelineCard extends StatelessWidget {
  final String mealType;
  final List<dynamic> items;
  final VoidCallback onAddMeal;

  const MealTimelineCard({
    super.key,
    required this.mealType,
    required this.items,
    required this.onAddMeal,
  });

  IconData _getMealIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.wb_sunny_rounded;
      case 'BRUNCH':
        return Icons.free_breakfast_rounded;
      case 'LUNCH':
        return Icons.lunch_dining_rounded;
      case 'AFTERNOON_TEA':
        return Icons.cake_rounded;
      case 'DINNER':
        return Icons.dinner_dining_rounded;
      case 'PRE_WORKOUT':
        return Icons.fitness_center_rounded;
      case 'POST_WORKOUT':
        return Icons.sports_gymnastics_rounded;
      case 'SNACK':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getMealColor(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
      case 'BRUNCH':
        return AppColors.yellowDark;
      case 'LUNCH':
        return AppColors.orangePrimary;
      case 'PRE_WORKOUT':
      case 'POST_WORKOUT':
        return AppColors.blueDark;
      case 'DINNER':
        return const Color(0xFF6366F1); // Indigo
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final totalCalories = items.fold<int>(0, (sum, item) {
      if (item is Map<String, dynamic>) {
        return sum + (item['calories'] as int? ?? 0);
      }
      return sum;
    });

    final mealColor = _getMealColor(mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: mealColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getMealIcon(mealType), color: mealColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.mealTypeName(mealType),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$totalCalories ${tr.text('kcal')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: totalCalories > 0 ? mealColor : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Add Button
              IconButton(
                onPressed: onAddMeal,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.orangePrimary,
                iconSize: 26,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Logged Food Items
          if (items.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final foodName = (item is Map<String, dynamic>)
                    ? (item['foodName'] as String? ?? 'Food Item')
                    : 'Food Item';
                final cals = (item is Map<String, dynamic>)
                    ? (item['calories'] as int? ?? 0)
                    : 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$cals ${tr.text('kcal')}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

