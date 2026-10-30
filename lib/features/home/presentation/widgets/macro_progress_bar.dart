import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';

/// แถบแสดงสัดส่วนสารอาหารหลัก 3 ชนิด (Protein, Carbs, Fat)
class MacroProgressBar extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double proteinPct;
  final double carbsPct;
  final double fatPct;

  const MacroProgressBar({
    super.key,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.text('macro_distribution'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.pie_chart_rounded, size: 20, color: AppColors.blueSecondary),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Columns: Protein, Carbs, Fat
          Row(
            children: [
              // Protein (Sky Blue)
              Expanded(
                child: _buildMacroItem(
                  label: tr.text('protein'),
                  grams: '${proteinG.toStringAsFixed(1)} ${tr.text('grams')}',
                  pct: '${proteinPct.toStringAsFixed(1)}%',
                  progressColor: AppColors.blueSecondary,
                  bgColor: AppColors.blueLight,
                  fraction: (proteinPct / 100).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 12),

              // Carbs (Honey Yellow)
              Expanded(
                child: _buildMacroItem(
                  label: tr.text('carbs'),
                  grams: '${carbsG.toStringAsFixed(1)} ${tr.text('grams')}',
                  pct: '${carbsPct.toStringAsFixed(1)}%',
                  progressColor: AppColors.yellowAccent,
                  bgColor: AppColors.yellowLight,
                  fraction: (carbsPct / 100).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 12),

              // Fat (Soft Pink)
              Expanded(
                child: _buildMacroItem(
                  label: tr.text('fat'),
                  grams: '${fatG.toStringAsFixed(1)} ${tr.text('grams')}',
                  pct: '${fatPct.toStringAsFixed(1)}%',
                  progressColor: AppColors.fatPink,
                  bgColor: AppColors.fatLight,
                  fraction: (fatPct / 100).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String grams,
    required String pct,
    required Color progressColor,
    required Color bgColor,
    required double fraction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                pct,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            grams,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

