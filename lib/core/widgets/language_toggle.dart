import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../localization/locale_provider.dart';

/// ปุ่มสลับภาษาแบบ segmented (TH | EN) มีแถบเลื่อนแบบนุ่มนวล
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  static const double _width = 96;
  static const double _height = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThai = ref.watch(localeProvider).languageCode == 'th';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggleLanguage(),
      child: Container(
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: isThai ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: (_width - 6) / 2,
                decoration: BoxDecoration(
                  gradient: AppColors.sunrise,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Row(
              children: [
                _label('TH', isThai),
                _label('EN', !isThai),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool active) {
    return Expanded(
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textTertiary,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

