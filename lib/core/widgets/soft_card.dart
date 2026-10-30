import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// การ์ดสไตล์ Soft 3D Claymorphism:
/// มีขอบแสงสีขาว (White Bevel Highlight) + เงาสองชั้น (Dual Shadow)
/// ทำให้การ์ดดูลอยนูน มีมิติสัมผัส เข้ากับอิโมจิ 3D อย่างเป็นธรรมชาติ
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.surface,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient ??
            LinearGradient(
              colors: [Colors.white, color],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: AppColors.clayShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
