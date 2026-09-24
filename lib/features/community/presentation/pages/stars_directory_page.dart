import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../domain/entities/star_profile.dart';

class StarsDirectoryPage extends StatefulWidget {
  const StarsDirectoryPage({super.key});

  @override
  State<StarsDirectoryPage> createState() => _StarsDirectoryPageState();
}

class _StarsDirectoryPageState extends State<StarsDirectoryPage> {
  String _selectedRole = 'All';

  final List<String> _roles = ['All', 'Voice Actor', 'Director', 'Creator', 'Idol'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fandom Stars Directory', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          if (state is! CommunityLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final stars = state.starProfiles.where((s) {
            if (_selectedRole == 'All') return true;
            return s.role.toLowerCase().contains(_selectedRole.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: _roles.map((r) {
                    final isSelected = _selectedRole == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(r),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = r;
                          });
                        },
                        selectedColor: isDark
                            ? AppColors.darkSecondary.withValues(alpha: 0.25)
                            : AppColors.lightPrimary.withValues(alpha: 0.15),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),

              // Stars Grid
              Expanded(
                child: stars.isEmpty
                    ? const Center(child: Text('No star profiles found in this category.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: stars.length,
                        itemBuilder: (context, index) {
                          final star = stars[index];
                          return _buildStarCard(context, star, isDark);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStarCard(BuildContext context, StarProfile star, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/star-detail', arguments: star);
      },
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      star.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.darkSurfaceElevated,
                        child: const Icon(Icons.person_rounded, size: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          star.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 16,
                          color: star.isBookmarked ? AppColors.darkAccentGold : Colors.white,
                        ),
                        onPressed: () {
                          context.read<CommunityBloc>().add(ToggleStarBookmarkEvent(star.id));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      star.role,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.darkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    star.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    star.knownFor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 12, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${star.followersCount} fans',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
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
