import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../localization/locale_provider.dart';

/// ปุ่มสลับภาษา TH | EN สไตล์โมเดิร์น สบายตา
class LanguageSwitcherButton extends ConsumerWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isThai = currentLocale.languageCode == 'th';

    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).toggleLanguage();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isThai ? AppColors.orangeLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🇹🇭 TH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isThai ? FontWeight.bold : FontWeight.w500,
                  color: isThai ? AppColors.orangePrimary : AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: !isThai ? AppColors.blueLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🇬🇧 EN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: !isThai ? FontWeight.bold : FontWeight.w500,
                  color: !isThai ? AppColors.blueDark : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

