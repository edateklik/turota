import 'package:flutter/material.dart';

// Colors from the provided HTML design
const Color _cPrimary = Color(0xFF008B8B);
const Color _cPrimaryFixedDim = Color(0xFF4DB8B8);
const Color _cSurface = Color(0xFFFBFAF8);
const Color _cOutline = Color(0xFFCBD5E1);

// Approximated Tailwind grays used in the HTML
const Color _cGray900 = Color(0xFF111827);
const Color _cGray800 = Color(0xFF1F2937);
const Color _cGray700 = Color(0xFF374151);
const Color _cGray500 = Color(0xFF6B7280);
const Color _cGray400 = Color(0xFF9CA3AF);
const Color _cGray200 = Color(0xFFE5E7EB);
const Color _cGray100 = Color(0xFFF3F4F6);
const Color _cGray50 = Color(0xFFF9FAFB);

class GastronomyPage extends StatelessWidget {
  const GastronomyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cSurface,
      appBar: AppBar(
        backgroundColor: _cSurface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'TUROTA',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _cPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _cOutline.withValues(alpha: 0.3)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/seed/useravatar/100/100',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _cOutline.withValues(alpha: 0.3), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastronomi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w800,
                      color: _cGray900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İstanbul\'un en iyi lezzet duraklarını keşfet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Public Sans',
                      color: _cGray500,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Restoran, kafe veya yemek ara...',
                    hintStyle: TextStyle(
                      color: _cGray400,
                      fontFamily: 'Public Sans',
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(Icons.search, color: _cGray400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mood Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _MoodChip(icon: '☕', label: 'Kahve', isSelected: true),
                  _MoodChip(icon: '🥐', label: 'Kahvaltı'),
                  _MoodChip(icon: '🍷', label: 'Romantik'),
                  _MoodChip(icon: '👨‍👩‍👧', label: 'Aile'),
                  _MoodChip(icon: '💻', label: 'Çalışmalık'),
                  _MoodChip(icon: '🥂', label: 'Lüks'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(label: 'En Yüksek Puan', icon: '⭐'),
                  _FilterChip(label: 'Fiyat', icon: '💰'),
                  _FilterChip(label: 'Yakınımda', icon: '📍'),
                  _FilterChip(label: 'Açık', icon: '🕒'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Hero Card: Editörün Seçimi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editörün Seçimi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.bold,
                      color: _cGray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              'https://picsum.photos/seed/neolokal/800/500',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_border,
                                  color: _cGray700,
                                  size: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.9',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _cGray900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Neolokal',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.bold,
                                      color: _cGray900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Modern Anadolu Mutfağı',
                                style: TextStyle(
                                  color: _cPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Karaköy\'ün kalbinde, geleneksel tatları modern bir dokunuşla yeniden yorumlayan ödüllü bir gastronomi deneyimi.',
                                style: TextStyle(
                                  color: _cGray500,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _cGray900,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Detaylar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _cGray100,
                                        foregroundColor: _cGray900,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.map, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Haritada Gör',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 32),

            // AI Recommendation Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: _cPrimaryFixedDim,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TUROTA AI Asistan',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: _cPrimaryFixedDim,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün hava serin. Sana kapalı ve sakin kahve mekanlarını öneriyoruz.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _cGray800,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _cPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'AI Rotası Oluştur',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Trend Mekanlar (Horizontal Carousel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trend Mekanlar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.bold,
                      color: _cGray900,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Tümü',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: _cPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: _cPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TrendCard(
                    imageUrl: 'https://picsum.photos/seed/bakery/300/200',
                    title: 'Brekkie Croissant',
                    subtitle: 'Kadıköy • Kahvaltı & Unlu Mamüller',
                    distance: '2.5 km',
                    rating: '4.8',
                  ),
                  const SizedBox(width: 16),
                  _TrendCard(
                    imageUrl: 'https://picsum.photos/seed/bar/300/200',
                    title: 'Alexandra Cocktail Bar',
                    subtitle: 'Arnavutköy • Kokteyl & Manzara',
                    distance: '5.1 km',
                    rating: '4.7',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sana Yakın (Vertical List)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sana Yakın',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.bold,
                      color: _cGray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NearbyListItem(
                    imageUrl: 'https://picsum.photos/seed/coffee1/150/150',
                    title: 'Petra Roasting Co.',
                    subtitle: 'Nitelikli Kahve & Atıştırmalıklar',
                    distance: '1.2 km',
                    rating: '4.6',
                    isOpen: true,
                  ),
                  const SizedBox(height: 16),
                  _NearbyListItem(
                    imageUrl: 'https://picsum.photos/seed/simit/150/150',
                    title: 'Tarihi Karaköy Simitçisi',
                    subtitle: 'Geleneksel Sokak Lezzeti',
                    distance: '1.5 km',
                    rating: '4.9',
                    isOpen: false,
                  ),
                  const SizedBox(height: 16),
                  _NearbyListItem(
                    imageUrl: 'https://picsum.photos/seed/vegan/150/150',
                    title: 'Bi Nevi Deli',
                    subtitle: 'Vegan & Glutensiz Seçenekler',
                    distance: '2.1 km',
                    rating: '4.5',
                    isOpen: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  final String icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [_cPrimary, Color(0xFF20B2AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? Colors.transparent : _cGray100),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : _cGray700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon});

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cGray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _cGray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.rating,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String distance;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256, // Fixed width matching w-64
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _cGray900,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _cGray500, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: _cGray400),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(
                        color: _cGray400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyListItem extends StatelessWidget {
  const _NearbyListItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.rating,
    required this.isOpen,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String distance;
  final String rating;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cGray50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _cGray900,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _cGray900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _cGray500, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: _cGray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: const TextStyle(
                            color: _cGray400,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOpen ? 'Açık' : 'Kapalı',
                          style: TextStyle(
                            color: isOpen ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
