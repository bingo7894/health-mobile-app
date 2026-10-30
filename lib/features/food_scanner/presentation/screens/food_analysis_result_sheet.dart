import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/utils/image_compressor_helper.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';
import '../../data/models/food_analysis_model.dart';

class FoodAnalysisResultSheet extends ConsumerStatefulWidget {
  final FoodAnalysisModel analysis;
  final File imageFile;
  final CompressedImageResult? compression;
  final String? initialMealType;
  final AppTranslations tr;

  const FoodAnalysisResultSheet({
    super.key,
    required this.analysis,
    required this.imageFile,
    this.compression,
    this.initialMealType,
    required this.tr,
  });

  static Future<bool?> show(
    BuildContext context, {
    required FoodAnalysisModel analysis,
    required File imageFile,
    CompressedImageResult? compression,
    String? initialMealType,
    required AppTranslations tr,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodAnalysisResultSheet(
        analysis: analysis,
        imageFile: imageFile,
        compression: compression,
        initialMealType: initialMealType,
        tr: tr,
      ),
    );
  }

  @override
  ConsumerState<FoodAnalysisResultSheet> createState() =>
      _FoodAnalysisResultSheetState();
}

class _FoodAnalysisResultSheetState
    extends ConsumerState<FoodAnalysisResultSheet> {
  late String _selectedMealType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? _guessMealType();
  }

  String _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'BREAKFAST';
    if (hour >= 11 && hour < 16) return 'LUNCH';
    if (hour >= 16 && hour < 21) return 'DINNER';
    return 'SNACK';
  }

  Future<void> _handleSaveMeal() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final tr = widget.tr;
    final analysis = widget.analysis;

    try {
      final ok = await ref.read(nutritionDataSourceProvider).logMeal(
            userId: kDefaultUserId,
            mealType: _selectedMealType,
            foodName: analysis.thaiName.isNotEmpty
                ? analysis.thaiName
                : analysis.foodName,
            portionWeightGrams: analysis.portionWeightGrams,
            cookingMethod: analysis.cookingMethod,
            calories: analysis.calories,
            proteinG: analysis.proteinG,
            carbsG: analysis.carbsG,
            fatG: analysis.fatG,
            sodiumMg: analysis.sodiumMg,
            sugarG: analysis.sugarG,
            fiberG: analysis.fiberG,
          );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (ok) {
        ref.invalidate(dailySummaryProvider);
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.text('meal_save_failed')),
            backgroundColor: AppColors.rose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.rose,
          ),
        );
      }
    }
  }

  Future<void> _handleDiscard() async {
    final tr = widget.tr;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          tr.text('confirm_discard_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          tr.text('confirm_discard_desc'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.text('keep_editing'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              tr.text('discard_confirm'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    final compression = widget.compression;
    final tr = widget.tr;
    final confPercent = (analysis.confidenceScore * 100).toStringAsFixed(0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable content
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                // Image preview with 3D frame
                Center(
                  child: Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: AppColors.clayShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Compression savings pill (if available)
                if (compression != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Text(
                        '⚡ ${compression.originalSizeKb} ➔ ${compression.compressedSizeKb} (-${compression.reductionPercent.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mint,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Food Title + Badges
                SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  analysis.thaiName,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  analysis.foodName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FluentEmoji(
                                  FluentEmojiName.fire,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${analysis.calories} kcal',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _TagChip(
                            label:
                                '~${analysis.portionWeightGrams.toStringAsFixed(0)} g',
                            bg: AppColors.surfaceMuted,
                            color: AppColors.textPrimary,
                          ),
                          _TagChip(
                            label: 'AI $confPercent%',
                            bg: AppColors.skySoft,
                            color: AppColors.skyDeep,
                          ),
                          _TagChip(
                            label: analysis.cookingMethod,
                            bg: AppColors.butterSoft,
                            color: AppColors.butterDeep,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Macro breakdown strip
                SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MacroMiniTile(
                          emoji: FluentEmojiName.fish,
                          label: tr.text('protein'),
                          value: '${analysis.proteinG.toStringAsFixed(0)}g',
                          color: AppColors.skyDeep,
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.divider),
                      Expanded(
                        child: _MacroMiniTile(
                          emoji: FluentEmojiName.rice,
                          label: tr.text('carbs'),
                          value: '${analysis.carbsG.toStringAsFixed(0)}g',
                          color: AppColors.butterDeep,
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.divider),
                      Expanded(
                        child: _MacroMiniTile(
                          emoji: FluentEmojiName.avocado,
                          label: tr.text('fat'),
                          value: '${analysis.fatG.toStringAsFixed(0)}g',
                          color: AppColors.rose,
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.divider),
                      Expanded(
                        child: _MacroMiniTile(
                          emoji: FluentEmojiName.potOfFood,
                          label: 'Sodium',
                          value: '${analysis.sodiumMg.toStringAsFixed(0)}mg',
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Ingredients List
                if (analysis.ingredients.isNotEmpty) ...[
                  SoftCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.text('ingredients'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: analysis.ingredients
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Dietitian Advice
                if (analysis.healthTips.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.butterSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FluentEmoji(FluentEmojiName.sun, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr.text('dietitian_advice'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.butterDeep,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                analysis.healthTips,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Meal Category Selector
                Text(
                  tr.text('select_meal_category'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'BREAKFAST',
                    'LUNCH',
                    'DINNER',
                    'SNACK',
                    'PRE_WORKOUT',
                  ].map((type) {
                    final isSelected = _selectedMealType == type;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedMealType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySoft
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow:
                                isSelected ? AppColors.clayShadow : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FluentEmoji.forMealType(type, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                tr.mealTypeName(type),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryDeep
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 1. Primary Action: Save Meal Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _isSaving ? null : _handleSaveMeal,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _isSaving ? null : AppColors.sunrise,
                          color: _isSaving ? AppColors.surfaceMuted : null,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.clayShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryDeep,
                                  strokeWidth: 2.5,
                                ),
                              )
                            else ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${tr.text('save_meal_btn')} (+${analysis.calories} kcal)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Secondary Action: Smart Portion (Full width, zero truncation)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${analysis.thaiName} (${analysis.calories} kcal) พร้อมเข้าสู่ระบบ Smart Portion (Task 3.3)',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 19,
                      color: AppColors.primaryDeep,
                    ),
                    label: Text(
                      tr.text('proceed_to_portion'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.3,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Destructive Action: Discard / Retake
                Center(
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _handleDiscard,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 17,
                      color: AppColors.rose,
                    ),
                    label: Text(
                      tr.text('discard_meal_btn'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rose,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color color;

  const _TagChip({required this.label, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MacroMiniTile extends StatelessWidget {
  final FluentEmojiName emoji;
  final String label;
  final String value;
  final Color color;

  const _MacroMiniTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FluentEmoji(emoji, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
