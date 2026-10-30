import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/food_loading_animation.dart';
import '../providers/food_scan_controller.dart';
import '../widgets/not_food_dialog.dart';
import 'food_analysis_result_sheet.dart';

class FoodScannerScreen extends ConsumerStatefulWidget {
  final String? mealType;

  const FoodScannerScreen({super.key, this.mealType});

  static Future<void> push(BuildContext context, {String? mealType}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FoodScannerScreen(mealType: mealType),
      ),
    );
  }

  @override
  ConsumerState<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends ConsumerState<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _capture(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );

      if (picked == null || !mounted) return;

      final file = File(picked.path);
      await _runScanPipeline(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _runScanPipeline(File file) async {
    final tr = ref.read(appTranslationsProvider);
    final controller = ref.read(foodScanControllerProvider.notifier);

    // Show 3D Food Loading Dialog
    FoodLoadingDialog.show(
      context,
      title: tr.text('verifying_food'),
      subtitle: tr.text('loading_ai_desc'),
    );

    try {
      await controller.processImage(file);
    } finally {
      if (mounted) {
        FoodLoadingDialog.hide(context);
      }
    }

    if (!mounted) return;

    final state = ref.read(foodScanControllerProvider);

    if (state.status == FoodScanStatus.notFood) {
      final label = state.gatekeeperResult?.matchedLabel ?? 'Unknown';
      final conf = state.gatekeeperResult?.confidence ?? 0.0;

      NotFoodDialog.show(
        context,
        detectedLabel: label,
        confidence: conf,
        tr: tr,
        onRetake: () => _capture(ImageSource.camera),
        onPickGallery: () => _capture(ImageSource.gallery),
      );
    } else if (state.status == FoodScanStatus.success &&
        state.analysisResult != null) {
      FoodAnalysisResultSheet.show(
        context,
        analysis: state.analysisResult!,
        imageFile: state.compressedResult?.file ?? file,
        compression: state.compressedResult,
        tr: tr,
      );
    } else if (state.status == FoodScanStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Analysis failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(foodScanControllerProvider);
    final tr = ref.watch(appTranslationsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Viewfinder simulation background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [Color(0xFF262835), Color(0xFF0F1016)],
              ),
            ),
          ),

          // Center Viewfinder Target Frame
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withAlpha(70),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 4 Corner brackets
                      const _CornerBracket(
                        alignment: Alignment.topLeft,
                        corners: [true, false, false, false],
                      ),
                      const _CornerBracket(
                        alignment: Alignment.topRight,
                        corners: [false, true, false, false],
                      ),
                      const _CornerBracket(
                        alignment: Alignment.bottomLeft,
                        corners: [false, false, true, false],
                      ),
                      const _CornerBracket(
                        alignment: Alignment.bottomRight,
                        corners: [false, false, false, true],
                      ),
                      Center(
                        child: Text(
                          tr.text('scan_hint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top App Bar Controls
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (widget.mealType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tr.mealTypeName(widget.mealType!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Capture Controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pick from Gallery Button
                    Expanded(
                      child: _BottomCircleAction(
                        icon: Icons.photo_library_rounded,
                        label: tr.text('gallery'),
                        onTap: () => _capture(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Main 3D Shutter Camera Button
                    GestureDetector(
                      onTap: () => _capture(ImageSource.camera),
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(120),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.sunrise,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick Switch
                    Expanded(
                      child: _BottomCircleAction(
                        icon: Icons.flip_camera_ios_rounded,
                        label: 'Switch',
                        onTap: () => _capture(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomCircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(40),
              border: Border.all(color: Colors.white.withAlpha(90), width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(190),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  final List<bool> corners; // [tl, tr, bl, br]

  const _CornerBracket({required this.alignment, required this.corners});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            top: corners[0] || corners[1]
                ? const BorderSide(color: AppColors.primary, width: 3.5)
                : BorderSide.none,
            bottom: corners[2] || corners[3]
                ? const BorderSide(color: AppColors.primary, width: 3.5)
                : BorderSide.none,
            left: corners[0] || corners[2]
                ? const BorderSide(color: AppColors.primary, width: 3.5)
                : BorderSide.none,
            right: corners[1] || corners[3]
                ? const BorderSide(color: AppColors.primary, width: 3.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

