import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/soft_card.dart';

/// การ์ดหลักแสดงสมดุลแคลอรีประจำวัน:
/// วงโค้ง Sunrise Arc พร้อมหัวใจเปลวไฟ 3D และเสาสรุปผล 3 มิติ
class CalorieHeroCard extends StatelessWidget {
  final int dailyGoal;
  final int eaten;
  final int burned;
  final AppTranslations tr;

  const CalorieHeroCard({
    super.key,
    required this.dailyGoal,
    required this.eaten,
    required this.burned,
    required this.tr,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBudget = dailyGoal + burned;
    final remaining = effectiveBudget - eaten;
    final isOver = remaining < 0;
    final progress = effectiveBudget > 0
        ? (eaten / effectiveBudget).clamp(0.0, 1.0)
        : 0.0;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        children: [
          // Arc Gauge centered with generous breathing room
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return SizedBox(
                width: 200,
                height: 158,
                child: CustomPaint(
                  painter: _SunriseArcPainter(
                    progress: animatedProgress,
                    isOver: isOver,
                  ),
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 14, left: 24, right: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 3D Fire Pod / Over Goal Warning
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isOver
                                  ? AppColors.errorSoft
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isOver ? AppColors.error : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isOver
                                          ? AppColors.error
                                          : AppColors.primary)
                                      .withAlpha(50),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: isOver
                                ? const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 20,
                                    color: AppColors.error,
                                  )
                                : const FluentEmoji(
                                    FluentEmojiName.fire,
                                    size: 28,
                                  ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${remaining.abs()}',
                              style: TextStyle(
                                fontSize: 36,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                                color: isOver
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tr.text(isOver ? 'over_goal' : 'remaining'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Bottom 3-column summary strip with 3D bevel (Goal | Eaten | Burned)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0DB4783C),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.flag_rounded,
                      iconColor: AppColors.skyDeep,
                      iconBg: AppColors.skySoft,
                      label: tr.text('goal'),
                      value: '$dailyGoal',
                      unit: tr.text('kcal'),
                    ),
                  ),
                  Container(width: 1, color: AppColors.border),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.restaurant_rounded,
                      iconColor: AppColors.primaryDeep,
                      iconBg: AppColors.primarySoft,
                      label: tr.text('eaten'),
                      value: '$eaten',
                      unit: tr.text('kcal'),
                    ),
                  ),
                  Container(width: 1, color: AppColors.border),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.butterDeep,
                      iconBg: AppColors.butterSoft,
                      label: tr.text('burned'),
                      value: '$burned',
                      unit: tr.text('kcal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Icon(icon, size: 13, color: iconColor),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunriseArcPainter extends CustomPainter {
  final double progress;
  final bool isOver;

  _SunriseArcPainter({required this.progress, required this.isOver});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = math.min(size.width / 2, size.height * 0.56) - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = math.pi * 0.80; // ~144 deg
    const sweepTotal = math.pi * 1.40; // ~252 deg open bottom horseshoe

    final trackPaint = Paint()
      ..color = AppColors.primarySoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);

    if (progress <= 0.005) return;

    final gradientColors = isOver
        ? [AppColors.error, AppColors.primaryDeep]
        : [AppColors.butter, AppColors.primary, AppColors.sky];

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepTotal * progress.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SunriseArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isOver != isOver;
  }
}
