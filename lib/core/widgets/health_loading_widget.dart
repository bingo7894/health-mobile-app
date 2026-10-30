import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';

/// วิดเจ็ตแอนิเมชัน Loading เกี่ยวกับอาหารและสุขภาพ (รองรับ Lottie พร้อม Fallback Health Animation ที่สวยงาม)
class HealthLoadingWidget extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final String? lottieAsset;

  const HealthLoadingWidget({
    super.key,
    this.message,
    this.subMessage,
    this.lottieAsset,
  });

  /// แสดง Loading Dialog เต็มหน้าจอ
  static void show(BuildContext context, {String? message, String? subMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(89),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: HealthLoadingWidget(
          message: message,
          subMessage: subMessage,
        ),
      ),
    );
  }

  /// ปิด Loading Dialog
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  State<HealthLoadingWidget> createState() => _HealthLoadingWidgetState();
}

class _HealthLoadingWidgetState extends State<HealthLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation Graphic: Lottie if provided, or Animated Health Glow
            if (widget.lottieAsset != null)
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  widget.lottieAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildAnimatedHealthGlow(),
                ),
              )
            else
              _buildAnimatedHealthGlow(),

            const SizedBox(height: 18),

            // Message Title
            if (widget.message != null) ...[
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Sub message
            if (widget.subMessage != null)
              Text(
                widget.subMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHealthGlow() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring (Soft Orange / Yellow)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.orangePrimary.withAlpha(46),
                        AppColors.yellowAccent.withAlpha(15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Inner Glass Circle
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.orangePrimary.withAlpha(76),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.orangePrimary,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

