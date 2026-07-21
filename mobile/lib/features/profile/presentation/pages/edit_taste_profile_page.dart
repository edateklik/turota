import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import '../controllers/edit_taste_profile_controller.dart';

class EditTasteProfilePage extends ConsumerStatefulWidget {
  const EditTasteProfilePage({super.key});

  @override
  ConsumerState<EditTasteProfilePage> createState() =>
      _EditTasteProfilePageState();
}

class _EditTasteProfilePageState extends ConsumerState<EditTasteProfilePage> {
  bool _isSaving = false;

  final categoriesMap = {
    '30000000-0000-0000-0000-000000000002': {'name': 'Gastronomi', 'icon': Icons.restaurant},
    '30000000-0000-0000-0000-000000000005': {'name': 'Sanat ve Kültür', 'icon': Icons.palette},
    '30000000-0000-0000-0000-000000000003': {'name': 'Müze', 'icon': Icons.museum},
    '30000000-0000-0000-0000-000000000004': {'name': 'Doğa / Park', 'icon': Icons.park},
    '30000000-0000-0000-0000-000000000006': {'name': 'Alışveriş', 'icon': Icons.shopping_bag},
    '30000000-0000-0000-0000-000000000001': {'name': 'Kafe', 'icon': Icons.local_cafe},
  };

  final tagsMap = {
    '40000000-0000-0000-0000-000000000003': {'name': 'Manzaralı', 'icon': Icons.landscape},
    '40000000-0000-0000-0000-000000000004': {'name': 'Tarihi', 'icon': Icons.history_edu},
    '40000000-0000-0000-0000-000000000006': {'name': 'Gece Açık', 'icon': Icons.celebration},
    '40000000-0000-0000-0000-000000000002': {'name': 'Bütçe Dostu', 'icon': Icons.account_balance_wallet},
    '40000000-0000-0000-0000-000000000005': {'name': 'Vegan Seçenekli', 'icon': Icons.eco},
    '40000000-0000-0000-0000-000000000007': {'name': 'Evcil Hayvan Dostu', 'icon': Icons.pets},
    '40000000-0000-0000-0000-000000000001': {'name': 'Aile Dostu', 'icon': Icons.child_friendly},
    '40000000-0000-0000-0000-000000000008': {'name': 'Erişilebilir', 'icon': Icons.accessible},
  };

  final dietaryOptions = [
    {'value': 'Everything', 'label': 'Her şeyi yerim'},
    {'value': 'Vegetarian', 'label': 'Vejetaryen'},
    {'value': 'Vegan', 'label': 'Vegan'},
    {'value': 'GlutenFree', 'label': 'Glütensiz'},
    {'value': 'NoPreference', 'label': 'Farketmez'},
  ];

  final budgetOptions = [
    {'value': 'Economy', 'label': 'Ekonomik'},
    {'value': 'Moderate', 'label': 'Dengeli'},
    {'value': 'Premium', 'label': 'Premium'},
    {'value': 'Mixed', 'label': 'Karışık'},
  ];

  final distanceOptions = [
    {'value': 'WalkingDistance', 'label': 'Yürüme mesafesi'},
    {'value': 'Max3Km', 'label': 'En fazla 3 km'},
    {'value': 'Max10Km', 'label': 'En fazla 10 km'},
    {'value': 'CityWide', 'label': 'Şehir içi her yer'},
    {'value': 'Flexible', 'label': 'Farketmez'},
  ];

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      await ref.read(editTasteProfileControllerProvider.notifier).saveProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tat Profiliniz güncellendi!'),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tat profiliniz güncellenemedi.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(editTasteProfileControllerProvider);
    final controller = ref.read(editTasteProfileControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tat Profilini Düzenle',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (state) {
          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Kategoriler'),
                      _buildCategoriesSection(
                        state.preferredCategoryIds,
                        controller,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Etiketler'),
                      _buildTagsSection(state.preferredTagIds, controller),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Beslenme Tercihi'),
                      _buildSingleChoice(
                        options: dietaryOptions,
                        currentValue: state.dietaryPreference,
                        onChanged: (val) =>
                            controller.setDietaryPreference(val),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Bütçe Tercihi'),
                      _buildSingleChoice(
                        options: budgetOptions,
                        currentValue: state.budgetLevel,
                        onChanged: (val) => controller.setBudgetLevel(val),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle('Mesafe Tercihi'),
                      _buildSingleChoice(
                        options: distanceOptions,
                        currentValue: state.distancePreference,
                        onChanged: (val) =>
                            controller.setDistancePreference(val),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),

                // Bottom Fixed Save Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.md,
                      AppSpacing.screen,
                      AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.9),
                          AppColors.background.withOpacity(0),
                        ],
                      ),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.01 * 14,
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Text('Değişiklikleri Kaydet'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    List<String> selected,
    EditTasteProfileController controller,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categoriesMap.entries.map((e) {
        final isSelected = selected.contains(e.key);
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                e.value['icon'] as IconData,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
              const SizedBox(width: 6),
              Text(e.value['name'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => controller.toggleCategory(e.key),
          selectedColor: AppColors.primaryContainer,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withOpacity(0.5),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsSection(
    List<String> selected,
    EditTasteProfileController controller,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsMap.entries.map((e) {
        final isSelected = selected.contains(e.key);
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                e.value['icon'] as IconData,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
              const SizedBox(width: 6),
              Text(e.value['name'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => controller.toggleTag(e.key),
          selectedColor: AppColors.primaryContainer,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withOpacity(0.5),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleChoice({
    required List<Map<String, String>> options,
    required String? currentValue,
    required Function(String) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = currentValue == opt['value'];
        return ChoiceChip(
          label: Text(opt['label']!),
          selected: isSelected,
          onSelected: (val) {
            if (val) onChanged(opt['value']!);
          },
          selectedColor: AppColors.primaryContainer,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          showCheckmark: isSelected,
          checkmarkColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withOpacity(0.5),
          ),
        );
      }).toList(),
    );
  }
}
