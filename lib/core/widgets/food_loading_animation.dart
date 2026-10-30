import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';

/// แอนิเมชัน Loading ธีมอาหาร/สุขภาพ:
/// ชามสลัดลอยขึ้นลงเบา ๆ มีผลไม้/ผักหมุนรอบ ๆ
///
/// ถ้าส่ง [lottieAsset] (เช่น 'assets/animations/food_loading.json' จาก LottieFiles)
/// จะใช้ Lottie แทน และถ้าโหลดไฟล์ไม่ได้จะกลับมาใช้แอนิเมชันนี้อัตโนมัติ
class FoodLoadingAnimation extends StatefulWidget {
  final double size;
  final String? lottieAsset;

  const FoodLoadingAnimation({super.key, this.size = 150, this.lottieAsset});

  @override
  State<FoodLoadingAnimation> createState() => _FoodLoadingAnimationState();
}

class _FoodLoadingAnimationState extends State<FoodLoadingAnimation>
    with SingleTickerProviderStateMixin {
  static const _foods = ['🍎', '🥑', '🥕', '🍌', '🥦', '🍓'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    if (widget.lottieAsset != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          widget.lottieAsset!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildOrbit(size),
        ),
      );
    }
    return _buildOrbit(size);
  }

  Widget _buildOrbit(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final radius = size * 0.36;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft halo
              Container(
                width: size * 0.62,
                height: size * 0.62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.primarySoft, AppColors.butterSoft],
                  ),
                ),
              ),
              // Orbiting foods
              for (var i = 0; i < _foods.length; i++)
                _orbitItem(i, t, radius, size),
              // Bowl bobbing in the centre
              Transform.translate(
                offset: Offset(0, math.sin(t * math.pi * 4) * size * 0.025),
                child: Text('🥗', style: TextStyle(fontSize: size * 0.3)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orbitItem(int i, double t, double radius, double size) {
    final angle = 2 * math.pi * (t + i / _foods.length);
    final bounce = 1 + 0.12 * math.sin(2 * math.pi * (t * 2 + i / _foods.length));
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.92),
      child: Transform.scale(
        scale: bounce,
        child: Text(_foods[i], style: TextStyle(fontSize: size * 0.15)),
      ),
    );
  }
}

/// จุดสามจุดเด้งสลับสี ส้ม / ฟ้า / เหลือง
class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  static const _colors = [AppColors.primary, AppColors.sky, AppColors.butter];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_controller.value - i * 0.18) * 2 * math.pi;
            final dy = -math.max(0.0, math.sin(phase)) * 7;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: _colors[i], shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Dialog สำหรับตอนรอ AI / ค้นหาบาร์โค้ด
class FoodLoadingDialog {
  FoodLoadingDialog._();

  static void show(BuildContext context, {required String title, String? subtitle}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.textPrimary.withAlpha(90),
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FoodLoadingAnimation(size: 150),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
                const SizedBox(height: 18),
                const BouncingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

