import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';
import 'package:health_app/core/widgets/language_toggle.dart';
import 'package:health_app/core/widgets/soft_card.dart';
import 'package:health_app/features/food_scanner/presentation/screens/scan_options_sheet.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appTranslationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.text('fav_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const LanguageToggle(),
                ],
              ),
              const Spacer(),
              Center(
                child: SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 34,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.butterSoft,
                              AppColors.primarySoft,
                            ],
                          ),
                        ),
                        child: const FluentEmoji(
                          FluentEmojiName.bento,
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tr.text('fav_empty_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr.text('fav_empty_desc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: () => ScanOptionsSheet.show(context),
                        icon: const Icon(Icons.camera_alt_rounded, size: 19),
                        label: Text(tr.text('fav_cta')),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
