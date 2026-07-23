import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/discover_page.dart';
import 'package:turota_mobile/features/saved/presentation/pages/saved_page.dart';
import 'package:turota_mobile/features/assistant/presentation/pages/assistant_page.dart';
import 'package:turota_mobile/shared/widgets/turota_bottom_nav_scaffold.dart';

/// Shell page that hosts the bottom navigation bar and the four main tabs.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  Widget _buildBody() {
    return switch (_currentIndex) {
      0 => const DiscoverPage(),
      1 => const AssistantPage(), // Assuming Rota maps to Assistant or similar
      2 => const SavedPage(),
      3 => const ProfilePage(),
      _ => const _PlaceholderTab(label: 'Yakında'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return TurotaBottomNavScaffold(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() => _currentIndex = index);
      },
      onQrScanPressed: () async {
        final result = await Navigator.pushNamed(context, AppRouter.qrScanner);
        if (result != null && result is String) {
          // Handle the scanned QR code result here
          debugPrint('QR Scanned from shell: $result');
          // e.g. navigate to a place detail or show a dialog
        }
      },
      body: _buildBody(),
    );
  }
}

/// Placeholder tab for sections not yet implemented.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Bu sayfa yakında eklenecek',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
