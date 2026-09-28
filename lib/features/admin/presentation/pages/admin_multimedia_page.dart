import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/multimedia_service.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../../../../core/widgets/skewed_button.dart';

class AdminMultimediaPage extends StatefulWidget {
  const AdminMultimediaPage({super.key});

  @override
  State<AdminMultimediaPage> createState() => _AdminMultimediaPageState();
}

class _AdminMultimediaPageState extends State<AdminMultimediaPage> {
  final _searchController = TextEditingController();
  String _selectedType = 'All'; // 'All', 'fan_art', 'cosplay', 'video', 'podcast'

  final List<Map<String, String>> _typeFilters = const [
    {'label': 'All Media', 'value': 'All'},
    {'label': 'Fan Art', 'value': 'fan_art'},
    {'label': 'Cosplay', 'value': 'cosplay'},
    {'label': 'Videos', 'value': 'video'},
    {'label': 'Podcasts', 'value': 'podcast'},
  ];

  @override
  void initState() {
    super.initState();
    MultimediaService.instance.ensureInitialized();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF111216), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fan Media Manager',
              style: TextStyle(
                color: Color(0xFF111216),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.comicRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Media uploads · Always live',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Color(0xFF111216), size: 20),
            tooltip: 'Refresh & Sync',
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing multimedia with Cloudinary & Firestore...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.comicRed,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.comicRed,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Iconsax.add_circle, size: 20),
        label: const Text(
          'New Media',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        onPressed: () async {
          final res = await Navigator.of(context).pushNamed(
            '/admin/multimedia-edit',
            arguments: {'type': _selectedType == 'All' ? 'fan_art' : _selectedType},
          );
          if (res == true && mounted) {
            setState(() {});
          }
        },
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: MultimediaService.instance.streamItems(
          type: _selectedType == 'All' ? null : _selectedType,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.comicRed),
            );
          }

          final allItems = snapshot.data ?? [];
          final query = _searchController.text.toLowerCase().trim();
          final filtered = allItems.where((item) {
            if (query.isEmpty) return true;
            final title = (item['title'] ?? item['character'] ?? '').toString().toLowerCase();
            final fandom = (item['fandom'] ?? '').toString().toLowerCase();
            final creator = (item['artist'] ?? item['cosplayer'] ?? item['channel'] ?? item['host'] ?? '')
                .toString()
                .toLowerCase();
            return title.contains(query) || fandom.contains(query) || creator.contains(query);
          }).toList();

          return Column(
            children: [
              // Search & Filter Header (Solid White & Red)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Color(0xFF111216), fontSize: 13, fontWeight: FontWeight.w600),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search fan art, cosplay, videos, podcasts...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                        prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.comicRed, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter tabs (Solid Red & White)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _typeFilters.map((f) {
                          final isSelected = _selectedType == f['value'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _selectedType = f['value']!),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.comicRed : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.comicRed : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  f['label']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary bar (Solid Red & White)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} ITEMS FOUND',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.cloud, size: 14, color: AppColors.comicRed),
                        const SizedBox(width: 4),
                        const Text(
                          'Cloudinary CDN Hosted',
                          style: TextStyle(color: AppColors.comicRed, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.video_play, size: 48, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 12),
                            const Text(
                              'No multimedia items found',
                              style: TextStyle(color: Color(0xFF111216), fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "+ New Media" to create Fan Art, Cosplay, Video, or Podcast',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildMultimediaCard(item);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMultimediaCard(Map<String, dynamic> item) {
    final id = item['id'] as String? ?? '';
    final type = item['type'] as String? ?? 'fan_art';
    final title = item['title'] as String? ?? item['character'] as String? ?? 'Untitled';
    final fandom = item['fandom'] as String? ?? 'General';
    final imageUrl = item['imageUrl'] as String? ??
        item['thumbnailUrl'] as String? ??
        item['coverUrl'] as String? ??
        '';

    String creator = '';
    String meta = '';
    String typeLabel = 'Fan Art';
    IconData typeIcon = Iconsax.brush_1;

    switch (type) {
      case 'fan_art':
        creator = 'Artist: ${item['artist'] ?? 'Unknown'}';
        meta = '❤️ ${item['likes'] ?? 0} likes';
        typeLabel = 'Fan Art';
        typeIcon = Iconsax.brush_1;
        break;
      case 'cosplay':
        creator = 'Cosplayer: ${item['cosplayer'] ?? 'Unknown'}';
        meta = item['award'] != null && item['award'].toString().isNotEmpty
            ? '🏆 ${item['award']}'
            : '📍 ${item['event'] ?? 'Con Event'}';
        typeLabel = 'Cosplay';
        typeIcon = Iconsax.mask;
        break;
      case 'video':
        creator = 'Channel: ${item['channel'] ?? 'Unknown'}';
        meta = '⏱️ ${item['duration'] ?? '10:00'} • 👁️ ${item['views'] ?? '1.2M'}';
        typeLabel = 'Video';
        typeIcon = Iconsax.video_play;
        break;
      case 'podcast':
        creator = 'Host: ${item['host'] ?? 'Unknown'}';
        meta = '🎙️ ${item['episode'] ?? 'EP 01'} • ⏱️ ${item['duration'] ?? '45m'}';
        typeLabel = 'Podcast';
        typeIcon = Iconsax.microphone_2;
        break;
    }

    final isCloudinary = CloudinaryService.isCloudinaryUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media banner / thumbnail row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppDisplayImage(
                        pathOrUrl: imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      if (isCloudinary)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Iconsax.cloud, color: Colors.white, size: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Solid Red tag & fandom text
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 10, color: AppColors.comicRed),
                                const SizedBox(width: 4),
                                Text(
                                  typeLabel,
                                  style: const TextStyle(
                                    color: AppColors.comicRed,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              fandom,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111216),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Creator
                      Text(
                        creator,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Meta
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action divider & button row (Solid Red & White)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCloudinary ? Iconsax.cloud : Iconsax.global,
                      size: 12,
                      color: isCloudinary ? AppColors.comicRed : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCloudinary ? 'Cloudinary CDN' : 'Web URL',
                      style: TextStyle(
                        color: isCloudinary ? AppColors.comicRed : const Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: isCloudinary ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Edit button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Iconsax.edit_2, size: 14, color: Color(0xFF111216)),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final res = await Navigator.of(context).pushNamed(
                          '/admin/multimedia-edit',
                          arguments: item,
                        );
                        if (res == true && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 6),

                    // Delete button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Iconsax.trash, size: 14, color: AppColors.comicRed),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.comicRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _confirmDelete(context, id, title),
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

  void _confirmDelete(BuildContext ctx, String id, String title) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.trash, color: AppColors.comicRed, size: 20),
            SizedBox(width: 8),
            Text(
              'Delete Multimedia Item',
              style: TextStyle(color: Color(0xFF111216), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "$title" from the Multimedia Hub and Firestore?',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          SkewedButton(
            text: 'Delete Now',
            height: 40,
            fontSize: 12,
            backgroundColor: AppColors.comicRed,
            textColor: Colors.white,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                await MultimediaService.instance.deleteItem(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted "$title" successfully!'),
                      backgroundColor: AppColors.comicRed,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.comicRed),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
