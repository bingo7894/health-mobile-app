import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/locale_provider.dart';
import 'package:health_app/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:health_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:health_app/features/food_scanner/presentation/screens/scan_options_sheet.dart';
import 'package:health_app/features/home/presentation/screens/home_screen.dart';
import 'package:health_app/features/profile/presentation/screens/profile_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

/// แถบเมนูด้านล่างแบบสมมาตร 4 แท็บ + ปุ่มสแกนอาหารตรงกลาง:
/// [หน้าหลัก]  [สถิติ]   ( 📷 )   [เมนูโปรด]  [ฉัน]
class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  static const _screens = [
    HomeScreen(),
    AnalyticsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final tr = ref.watch(appTranslationsProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.sunrise,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDeep.withAlpha(110),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => ScanOptionsSheet.show(context),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: AppColors.softShadow,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.wb_sunny_outlined,
                    activeIcon: Icons.wb_sunny_rounded,
                    label: tr.text('nav_home'),
                    selected: currentTab == 0,
                    onTap: () =>
                        ref.read(currentTabProvider.notifier).state = 0,
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: tr.text('nav_stats'),
                    selected: currentTab == 1,
                    onTap: () =>
                        ref.read(currentTabProvider.notifier).state = 1,
                  ),
                ),
                // Space reserved for the center camera FAB
                const SizedBox(width: 72),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.favorite_border_rounded,
                    activeIcon: Icons.favorite_rounded,
                    label: tr.text('nav_favorites'),
                    selected: currentTab == 2,
                    onTap: () =>
                        ref.read(currentTabProvider.notifier).state = 2,
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: tr.text('nav_profile'),
                    selected: currentTab == 3,
                    onTap: () =>
                        ref.read(currentTabProvider.notifier).state = 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDeep : AppColors.textTertiary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: selected
                    ? Border.all(color: Colors.white, width: 1.2)
                    : null,
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x18B4783C),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
