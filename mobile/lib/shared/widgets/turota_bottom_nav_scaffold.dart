import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TurotaBottomNavScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onQrScanPressed;
  final bool showQrButton;
  final bool extendBody;

  const TurotaBottomNavScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQrScanPressed,
    this.showQrButton = true,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody, // Allows body to extend under the BottomAppBar
      body: body,
      floatingActionButton: showQrButton ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onQrScanPressed,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 32,
          ),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.surface,
        elevation: 8,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildTabItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Keşfet',
                index: 0,
              ),
              _buildTabItem(
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy,
                label: 'AI Asistan',
                index: 1,
              ),
              const SizedBox(width: 48), // Ortadaki QR butonu için boşluk
              _buildTabItem(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                label: 'Kaydedilenler',
                index: 2,
              ),
              _buildTabItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryContainer : AppColors.outline;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
