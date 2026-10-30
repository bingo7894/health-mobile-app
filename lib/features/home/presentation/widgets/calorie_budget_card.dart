import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';

/// การ์ดสรุปงบประมาณแคลอรีประจำวัน (Calorie Budget Card) สีส้ม-ฟ้า-เหลือง สบายตา
class CalorieBudgetCard extends StatelessWidget {
  final int consumedCalories;
  final int targetCalories;
  final int burnedCalories;

  const CalorieBudgetCard({
    super.key,
    required this.consumedCalories,
    this.targetCalories = 2000,
    this.burnedCalories = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final remainingCalories = (targetCalories - consumedCalories + burnedCalories).clamp(0, targetCalories * 2);
    final progress = (consumedCalories / targetCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
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
                tr.text('daily_summary'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tr.text('target')} $targetCalories ${tr.text('kcal')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Center Stats with Ring Indicator
          Row(
            children: [
              // Circular Progress Ring
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.orangeLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orangePrimary),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$remainingCalories',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          tr.text('remaining'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Detail Columns (Consumed & Burned)
              Expanded(
                child: Column(
                  children: [
                    // Consumed
                    _buildStatRow(
                      icon: Icons.restaurant_rounded,
                      iconColor: AppColors.orangePrimary,
                      iconBg: AppColors.orangeLight,
                      label: tr.text('consumed'),
                      value: '$consumedCalories ${tr.text('kcal')}',
                    ),
                    const SizedBox(height: 12),

                    // Burned
                    _buildStatRow(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.yellowDark,
                      iconBg: AppColors.yellowLight,
                      label: tr.text('burned'),
                      value: '$burnedCalories ${tr.text('kcal')}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

