import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';

class NotFoodDialog extends StatelessWidget {
  final String detectedLabel;
  final double confidence;
  final AppTranslations tr;
  final VoidCallback onRetake;
  final VoidCallback onPickGallery;

  const NotFoodDialog({
    super.key,
    required this.detectedLabel,
    required this.confidence,
    required this.tr,
    required this.onRetake,
    required this.onPickGallery,
  });

  static Future<void> show(
    BuildContext context, {
    required String detectedLabel,
    required double confidence,
    required AppTranslations tr,
    required VoidCallback onRetake,
    required VoidCallback onPickGallery,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotFoodDialog(
        detectedLabel: detectedLabel,
        confidence: confidence,
        tr: tr,
        onRetake: onRetake,
        onPickGallery: onPickGallery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confPercent = (confidence * 100).toStringAsFixed(0);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Warning Badge
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24E5675C),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.no_meals_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tr.text('no_food_detected_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr.text('no_food_detected_desc').replaceAll('{label}', detectedLabel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Label: $detectedLabel ($confPercent%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetake();
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(tr.text('retake_photo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPickGallery();
                },
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: Text(tr.text('pick_from_gallery')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

