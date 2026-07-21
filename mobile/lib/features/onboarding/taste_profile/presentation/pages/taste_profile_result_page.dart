import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import '../controllers/taste_profile_controller.dart';
import 'package:turota_mobile/shared/widgets/turota_action_button.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/update_taste_profile_request_dto.dart';

class TasteProfileResultPage extends ConsumerStatefulWidget {
  const TasteProfileResultPage({super.key});

  @override
  ConsumerState<TasteProfileResultPage> createState() =>
      _TasteProfileResultPageState();
}

class _TasteProfileResultPageState extends ConsumerState<TasteProfileResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();

    // Simulate saving profile to backend when arriving at this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasteProfileControllerProvider.notifier).saveProfile();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(tasteProfileControllerProvider);

    final categoriesMap = {
      'gastronomy': 'Gastronomi',
      'art': 'Sanat ve Kültür',
      'museum': 'Müze',
      'history': 'Tarihi Yerler',
      'nature': 'Doğa',
      'shopping': 'Alışveriş',
      'nightlife': 'Gece Hayatı',
      'cafe': 'Kafe',
    };

    final tagsMap = {
      'view': 'Manzaralı',
      'historic': 'Tarihi',
      'quiet': 'Sakin',
      'lively': 'Hareketli',
      'romantic': 'Romantik',
      'pet_friendly': 'Evcil Hayvan Dostu',
      'kid_friendly': 'Çocuk Dostu',
      'trendy': 'Popüler / Trend',
    };

    final dietaryMap = {
      'Everything': 'Her şeyi yerim',
      'Vegetarian': 'Vejetaryen',
      'Vegan': 'Vegan',
      'GlutenFree': 'Glütensiz',
      'NoPreference': 'Farketmez',
    };

    final budgetMap = {
      'Economy': 'Ekonomik',
      'Moderate': 'Dengeli',
      'Premium': 'Premium',
      'Mixed': 'Karışık',
    };

    final distanceMap = {
      'WalkingDistance': 'Yürüme mesafesi',
      'Max3Km': 'Max 3 km',
      'Max10Km': 'Max 10 km',
      'CityWide': 'Şehir içi',
      'Flexible': 'Farketmez',
    };

    final selectedCategoriesText = state.preferredCategoryIds.isEmpty
        ? 'Seçilmedi'
        : state.preferredCategoryIds
              .map((id) => categoriesMap[id] ?? id)
              .join(', ');

    final selectedTagsText = state.preferredTagIds.isEmpty
        ? 'Seçilmedi'
        : state.preferredTagIds.map((id) => tagsMap[id] ?? id).join(', ');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'TUROTA',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // Spacer to balance the leading icon
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 160),
                    children: [
                      // Hero Section
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.done_all,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Tat Profilin Hazır!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Artık sana tercihlerine göre kişiselleştirilmiş mekanlar ve rotalar önerebiliriz.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Summary Grid
                      // Using Wrap for responsive grid layout similar to web design
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSummaryCard(
                            context,
                            icon: Icons.restaurant,
                            title: 'Kategoriler',
                            value: selectedCategoriesText,
                          ),
                          _buildSummaryCard(
                            context,
                            icon: Icons.sell_outlined,
                            title: 'Etiketler',
                            value: selectedTagsText,
                          ),
                          _buildSummaryCard(
                            context,
                            icon: Icons.local_dining,
                            title: 'Beslenme',
                            value:
                                dietaryMap[state.dietaryPreference] ??
                                'Belirtilmedi',
                          ),
                          _buildSummaryCard(
                            context,
                            icon: Icons.payments_outlined,
                            title: 'Bütçe',
                            value:
                                budgetMap[state.budgetLevel] ?? 'Belirtilmedi',
                          ),
                          _buildSummaryCard(
                            context,
                            icon: Icons.location_on_outlined,
                            title: 'Uzaklık',
                            value:
                                distanceMap[state.distancePreference] ??
                                'Belirtilmedi',
                            isWide: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // AI Explanation Bento Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onBackground.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AKILLI EŞLEŞME',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Öneriler nasıl hazırlanıyor?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Yapay zekâ; sevdiğin kategorileri, mekan etiketlerini, beslenme tercihini, bütçeni ve başlangıç konumuna olan uzaklığı birlikte değerlendirerek her mekan için bir uygunluk puanı oluşturur.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Weightage Progress Bars
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer.withOpacity(
                                  0.3,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  _buildProgressItem(
                                    context,
                                    'Kategoriler',
                                    0.35,
                                    '35%',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProgressItem(
                                    context,
                                    'Etiketler',
                                    0.30,
                                    '30%',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProgressItem(
                                    context,
                                    'Beslenme',
                                    0.15,
                                    '15%',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProgressItem(
                                    context,
                                    'Bütçe',
                                    0.10,
                                    '10%',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProgressItem(
                                    context,
                                    'Uzaklık',
                                    0.10,
                                    '10%',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fixed Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.9),
                    colorScheme.surface.withOpacity(0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TurotaActionButton(
                      label: _isSaving ? 'Kaydediliyor...' : 'Keşfetmeye Başla',
                      icon: _isSaving ? Icons.hourglass_empty : Icons.explore,
                      onPressed: _isSaving ? null : _handleComplete,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate back to beginning of taste profile
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                        child: const Text('Tercihleri Düzenle'),
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isWide = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Roughly half width minus padding/spacing for grid items
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isWide ? screenWidth - 40 : (screenWidth - 56) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onBackground.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    double value,
    String percentage,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              percentage,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: value),
          builder: (context, animValue, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: animValue,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary.withOpacity(
                    value + 0.4 > 1 ? 1 : value + 0.4,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleComplete() async {
    setState(() => _isSaving = true);
    try {
      final state = ref.read(tasteProfileControllerProvider);
      final repository = ref.read(authRepositoryProvider);
      
      final request = UpdateTasteProfileRequestDto(
        preferredCategoryIds: state.preferredCategoryIds,
        preferredTagIds: state.preferredTagIds,
        dietaryPreference: state.dietaryPreference ?? 'NoPreference',
        budgetLevel: state.budgetLevel ?? 'Moderate',
        travelPace: 'Balanced',
        distancePreference: state.distancePreference ?? 'Flexible',
      );
      
      await repository.updateTasteProfile(request);
      
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profiliniz kaydedilirken bir hata oluştu.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
