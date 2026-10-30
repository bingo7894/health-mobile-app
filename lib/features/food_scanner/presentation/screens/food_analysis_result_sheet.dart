import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/utils/image_compressor_helper.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import '../../data/models/food_analysis_model.dart';

class FoodAnalysisResultSheet extends StatelessWidget {
  final FoodAnalysisModel analysis;
  final File imageFile;
  final CompressedImageResult? compression;
  final AppTranslations tr;

  const FoodAnalysisResultSheet({
    super.key,
    required this.analysis,
    required this.imageFile,
    this.compression,
    required this.tr,
  });

  static Future<void> show(
    BuildContext context, {
    required FoodAnalysisModel analysis,
    required File imageFile,
    CompressedImageResult? compression,
    required AppTranslations tr,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodAnalysisResultSheet(
        analysis: analysis,
        imageFile: imageFile,
        compression: compression,
        tr: tr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confPercent = (analysis.confidenceScore * 100).toStringAsFixed(0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
                        imageFile,
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
                        '⚡ ${compression!.originalSizeKb} ➔ ${compression!.compressedSizeKb} (-${compression!.reductionPercent.toStringAsFixed(0)}%)',
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

                // Action buttons: Smart Portion (Task 3.3 preview)
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  label: Text(tr.text('proceed_to_portion')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
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

