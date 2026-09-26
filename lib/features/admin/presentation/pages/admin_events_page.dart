import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_modals.dart';
import 'admin_event_edit_page.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: const Text(
          'Event Radar Manager',
          style: TextStyle(
            color: AppColors.adminLightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.adminLightTextPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Iconsax.location_add, color: Colors.white),
        label: const Text('New Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminEventEditPage(),
            ),
          );
        },
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD97706)));
          }

          final allEvents = state is AdminStatsLoaded ? state.events : [];
          final query = _searchController.text.toLowerCase().trim();

          final filtered = allEvents.where((e) {
            final title = (e['title'] ?? '').toString().toLowerCase();
            final city = (e['city_name'] ?? '').toString().toLowerCase();
            final venue = (e['venue_name'] ?? '').toString().toLowerCase();
            return query.isEmpty || title.contains(query) || city.contains(query) || venue.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search convention by name, city or venue...',
                    hintStyle: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 12),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.adminLightTextSecondary, size: 18),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Conventions Active',
                      style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No events found.',
                          style: TextStyle(color: AppColors.adminLightTextSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return _buildEventTile(context, event);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminLightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppDisplayImage(
              pathOrUrl: event['banner_url'] ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event['city_name'] ?? 'GLOBAL',
                        style: const TextStyle(color: Color(0xFFD97706), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'UPCOMING',
                        style: TextStyle(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  event['venue_name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'GPS: ${event['latitude']}, ${event['longitude']}',
                  style: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 10, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit_2, color: Color(0xFF2563EB), size: 18),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminEventEditPage(existingEvent: event),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error, size: 18),
                onPressed: () {
                  AdminModals.showDeleteBarrierDialog(
                    context: context,
                    itemName: event['title'] ?? 'Event',
                    onConfirmed: () {
                      context.read<AdminBloc>().add(DeleteEventEvent(event['event_id']));
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
