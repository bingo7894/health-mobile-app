import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';

/// การ์ดแสดงรายการอาหารของแต่ละมื้อ (เช้า / กลางวัน / เย็น / ของว่าง / มื้อพิเศษ)
/// สไตล์ Soft 3D Claymorphism พร้อมไอคอน Fluent Emoji 3D ขนาดใหญ่ชัดเจน
class MealSectionCard extends StatelessWidget {
  final String mealType;
  final List<MealEntryItem> items;
  final AppTranslations tr;
  final VoidCallback onAddTap;
  final ValueChanged<MealEntryItem>? onDeleteItem;
  final Widget? dragHandle;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.items,
    required this.tr,
    required this.onAddTap,
    this.onDeleteItem,
    this.dragHandle,
  });

  ({FluentEmojiName emoji, Color bg, Color accent, Gradient gradient})
      _styleForMeal(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return (
          emoji: FluentEmojiName.cooking,
          bg: AppColors.butterSoft,
          accent: AppColors.butterDeep,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9E8), Color(0xFFFFEDBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'LUNCH':
        return (
          emoji: FluentEmojiName.bento,
          bg: AppColors.primarySoft,
          accent: AppColors.primaryDeep,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3EC), Color(0xFFFFDFC9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'DINNER':
        return (
          emoji: FluentEmojiName.potOfFood,
          bg: AppColors.skySoft,
          accent: AppColors.skyDeep,
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF8FD), Color(0xFFD4EEFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'PRE_WORKOUT':
      case 'POST_WORKOUT':
        return (
          emoji: FluentEmojiName.lightning,
          bg: AppColors.mintSoft,
          accent: AppColors.mint,
          gradient: const LinearGradient(
            colors: [Color(0xFFECFAF5), Color(0xFFCEF4E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      default:
        return (
          emoji: FluentEmojiName.apple,
          bg: AppColors.roseSoft,
          accent: AppColors.rose,
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF0F4), Color(0xFFFBD7E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
              // 3D Clay Pod for Emoji Icon (56x56dp with White Highlight & Dual Shadows)
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: style.gradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: AppColors.badge3DShadow(style.accent),
                ),
                child: FluentEmoji(style.emoji, size: 38),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.mealTypeName(mealType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items.isEmpty
                          ? tr.text('meal_empty')
                          : '${tr.itemsCount(items.length)} · $totalKcal ${tr.text('kcal')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            items.isEmpty ? FontWeight.w500 : FontWeight.w700,
                        color: items.isEmpty
                            ? AppColors.textTertiary
                            : style.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3D Tactile Add Button (+) with Bevel & Lift
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF2E8), Color(0xFFFFDFCA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x20EE6F33),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAddTap,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
              ),

              // Drag Handle to Reorder Meal Position
              if (dragHandle != null) ...[
                const SizedBox(width: 6),
                dragHandle!,
              ],
            ],
          ),
          if (items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MealItemRow(
                item: items[i],
                tr: tr,
                onDelete: onDeleteItem,
              ),
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
  final ValueChanged<MealEntryItem>? onDelete;

  const _MealItemRow({
    required this.item,
    required this.tr,
    this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.roseSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.rose,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr.text('delete_food_title'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.foodName} (${item.calories} ${tr.text('kcal')})',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr.text('delete_food_desc'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.text('keep_editing'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: Text(tr.text('confirm_delete_btn')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && onDelete != null) {
      onDelete!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id ?? '${item.foodName}_${item.calories}'),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (_) async {
        await _confirmDelete(context);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.roseSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppColors.rose,
          size: 22,
        ),
      ),
      child: Row(
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
                    fontWeight: FontWeight.w700,
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
          const SizedBox(width: 8),

          // 3D Tactile Calorie Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10B4783C),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${item.calories} ${tr.text('kcal')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeep,
              ),
            ),
          ),

          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.rose,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: tr.text('delete_food_title'),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
    );
  }
}
