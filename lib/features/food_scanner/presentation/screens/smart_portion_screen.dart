import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';
import '../providers/smart_portion_controller.dart';

class SmartPortionScreen extends ConsumerWidget {
  final FoodAnalysisModel analysis;
  final File? imageFile;
  final String? initialMealType;

  const SmartPortionScreen({
    super.key,
    required this.analysis,
    this.imageFile,
    this.initialMealType,
  });

  static Future<bool?> push(
    BuildContext context, {
    required FoodAnalysisModel analysis,
    File? imageFile,
    String? initialMealType,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SmartPortionScreen(
          analysis: analysis,
          imageFile: imageFile,
          initialMealType: initialMealType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appTranslationsProvider);
    final mealType = initialMealType ?? 'LUNCH';
    final state = ref.watch(
      smartPortionControllerFamily((analysis: analysis, mealType: mealType)),
    );
    final controller = ref.read(
      smartPortionControllerFamily((analysis: analysis, mealType: mealType))
          .notifier,
    );

    final baseCalories = analysis.calories;
    final currentCalories = state.computed.calories;
    final diffCalories = currentCalories - baseCalories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          tr.text('smart_portion_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Food Header Card
                  SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        if (imageFile != null && imageFile!.existsSync())
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const FluentEmoji(
                              FluentEmojiName.cooking,
                              size: 32,
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.thaiName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                analysis.foodName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tr.text('base_ai_estimate')} ~${analysis.portionWeightGrams.round()}g (${analysis.calories} kcal)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Hero Calorie Display Card
                  SoftCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$currentCalories',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDeep,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Difference badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: diffCalories == 0
                                ? AppColors.surfaceMuted
                                : diffCalories > 0
                                    ? AppColors.primarySoft
                                    : AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            diffCalories == 0
                                ? 'ตรงกับค่ามาตรฐาน AI'
                                : diffCalories > 0
                                    ? '+$diffCalories kcal (+${((diffCalories / baseCalories) * 100).round()}%)'
                                    : '$diffCalories kcal (${((diffCalories / baseCalories) * 100).round()}%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: diffCalories == 0
                                  ? AppColors.textSecondary
                                  : diffCalories > 0
                                      ? AppColors.primaryDeep
                                      : AppColors.mint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Portion Slider Card
                  SoftCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tr.text('portion_grams'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stepper Controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StepperButton(
                                  icon: Icons.remove_rounded,
                                  onTap: () => controller.stepGrams(-10),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${state.targetWeightGrams.round()} ${tr.text('grams_unit')}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDeep,
                                    ),
                                  ),
                                ),
                                _StepperButton(
                                  icon: Icons.add_rounded,
                                  onTap: () => controller.stepGrams(10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surfaceMuted,
                            trackHeight: 6,
                            thumbColor: AppColors.primaryDeep,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 11,
                              elevation: 3,
                            ),
                            overlayColor: AppColors.primary.withAlpha(30),
                          ),
                          child: Slider(
                            value: state.targetWeightGrams,
                            min: 50.0,
                            max: 800.0,
                            divisions: 150,
                            onChanged: (val) => controller.setTargetGrams(val),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 4 Quick Preset Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            (0.5, tr.text('chip_half_portion')),
                            (1.0, tr.text('chip_single_portion')),
                            (1.5, tr.text('chip_one_half_portion')),
                            (2.0, tr.text('chip_double_portion')),
                          ].map((item) {
                            final ratio = item.$1;
                            final label = item.$2;
                            final isCurrent =
                                (state.computed.ratio - ratio).abs() < 0.08;

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => controller.setPortionRatio(ratio),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.primarySoft
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isCurrent
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.primaryDeep
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Live Nutrients Breakdown
                  Text(
                    tr.text('macro_breakdown'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MacroTile(
                          emoji: FluentEmojiName.fish,
                          label: tr.text('protein'),
                          value:
                              '${state.computed.proteinG.toStringAsFixed(1)}g',
                          color: AppColors.skyDeep,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroTile(
                          emoji: FluentEmojiName.rice,
                          label: tr.text('carbs'),
                          value:
                              '${state.computed.carbsG.toStringAsFixed(1)}g',
                          color: AppColors.butterDeep,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroTile(
                          emoji: FluentEmojiName.avocado,
                          label: tr.text('fat'),
                          value: '${state.computed.fatG.toStringAsFixed(1)}g',
                          color: AppColors.rose,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroTile(
                          emoji: FluentEmojiName.potOfFood,
                          label: 'Sodium',
                          value:
                              '${state.computed.sodiumMg.toStringAsFixed(0)}mg',
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

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
                      final isSelected = state.selectedMealType == type;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => controller.setMealType(type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySoft
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.6 : 1.0,
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Bottom Save Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: state.isSaving
                        ? null
                        : () async {
                            final ok = await controller.saveAdjustedMeal();
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${analysis.thaiName} (${state.computed.weightGrams.round()}g · +$currentCalories kcal) ${tr.text('meal_saved_success')}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              Navigator.of(context).pop(true);
                            }
                          },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: state.isSaving ? null : AppColors.sunrise,
                        color: state.isSaving ? AppColors.surfaceMuted : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.clayShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isSaving)
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
                                '${tr.text('save_adjusted_meal')} (+$currentCalories kcal)',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final FluentEmojiName emoji;
  final String label;
  final String value;
  final Color color;

  const _MacroTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          FluentEmoji(emoji, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
