import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/food_loading_animation.dart';
import 'food_scanner_screen.dart';

/// แผ่นเลือกวิธีบันทึกอาหาร (Bottom Sheet):
/// 1) ถ่ายรูปด้วย AI (การ์ดเด่นโทนส้ม Sunrise)
/// 2) สแกนบาร์โค้ด (โทนฟ้า Sky)
/// 3) พิมพ์เอง (โทนเหลืองนวล Butter)
class ScanOptionsSheet extends ConsumerWidget {
  final String? initialMealType;

  const ScanOptionsSheet({super.key, this.initialMealType});

  static Future<void> show(BuildContext context, {String? mealType}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanOptionsSheet(initialMealType: mealType),
    );
  }

  Future<void> _previewLoadingAndNotify(
    BuildContext context, {
    required String loadingTitle,
    required String loadingDesc,
    required String doneMessage,
  }) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();

    FoodLoadingDialog.show(
      rootNavigator.context,
      title: loadingTitle,
      subtitle: loadingDesc,
    );

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (rootNavigator.mounted && rootNavigator.canPop()) {
      rootNavigator.pop();
    }
    messenger?.showSnackBar(SnackBar(content: Text(doneMessage)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appTranslationsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.text('scan_title'),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tr.text('scan_subtitle'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (initialMealType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        tr.mealTypeName(initialMealType!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Featured Option 1: AI Camera (Sunrise Gradient)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    Navigator.of(context).pop();
                    FoodScannerScreen.push(
                      context,
                      mealType: initialMealType,
                    );
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.sunrise,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(55),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      tr.text('scan_ai_title'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.butterSoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tr.text('recommended'),
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.butterDeep,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr.text('scan_ai_desc'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withAlpha(235),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Barcode (Sky Blue)
              _SecondaryOptionTile(
                icon: Icons.qr_code_scanner_rounded,
                iconBg: AppColors.skySoft,
                iconColor: AppColors.skyDeep,
                title: tr.text('scan_barcode_title'),
                subtitle: tr.text('scan_barcode_desc'),
                onTap: () => _previewLoadingAndNotify(
                  context,
                  loadingTitle: tr.text('loading_barcode_title'),
                  loadingDesc: tr.text('loading_barcode_desc'),
                  doneMessage: tr.text('coming_soon'),
                ),
              ),
              const SizedBox(height: 12),

              // Option 3: Manual Entry (Butter Yellow)
              _SecondaryOptionTile(
                icon: Icons.edit_note_rounded,
                iconBg: AppColors.butterSoft,
                iconColor: AppColors.butterDeep,
                title: tr.text('scan_manual_title'),
                subtitle: tr.text('scan_manual_desc'),
                onTap: () {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.of(context).pop();
                  messenger?.showSnackBar(
                    SnackBar(content: Text(tr.text('coming_soon'))),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecondaryOptionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
