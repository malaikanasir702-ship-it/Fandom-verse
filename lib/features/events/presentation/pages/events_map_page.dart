import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/event_mock_data.dart';
import '../../domain/entities/event_entity.dart';

class EventsMapPage extends StatefulWidget {
  const EventsMapPage({super.key});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  double _radarRadiusKm = 50.0;
  String _selectedType = 'All';
  EventEntity? _selectedEvent;

  final List<String> _types = ['All', 'Anime', 'Comic Con', 'Gaming', 'K-Pop'];

  @override
  void initState() {
    super.initState();
    if (EventMockData.events.isNotEmpty) {
      _selectedEvent = EventMockData.events.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredEvents = EventMockData.events.where((e) {
      if (_selectedType == 'All') return true;
      return e.category.toLowerCase().contains(_selectedType.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Radar Map', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.location_tick),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centered on your current location: Los Angeles, CA'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated Radar / Geospatial Map Canvas
          Container(
            color: isDark ? const Color(0xFF0F121C) : const Color(0xFFE2E8F0),
            child: Stack(
              children: [
                // Radar concentric grid circles
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkSecondary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkSecondary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkSecondary.withValues(alpha: 0.05),
                      border: Border.all(
                        color: AppColors.darkSecondary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Iconsax.profile_circle, color: AppColors.darkSecondary, size: 28),
                    ),
                  ),
                ),

                // Simulated Event Radar Pins
                ...List.generate(filteredEvents.length, (index) {
                  final e = filteredEvents[index];
                  // Calculate dynamic positions around the center
                  final double angle = (index * (360 / (filteredEvents.isEmpty ? 1 : filteredEvents.length))) * (3.14159 / 180);
                  final double distance = 90.0 + (index % 3) * 40;
                  final double left = 180 + distance * (angle).abs().remainder(1.5) - 40;
                  final double top = 220 + distance * (angle).remainder(1.2) - 30;

                  final isSelected = _selectedEvent?.id == e.id;

                  return Positioned(
                    left: left.clamp(30.0, 320.0),
                    top: top.clamp(90.0, 480.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEvent = e;
                        });
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.darkSecondary : AppColors.darkPrimary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSelected ? AppColors.darkSecondary : AppColors.darkPrimary)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.ticket, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    e.cityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Iconsax.location,
                              color: isSelected ? AppColors.darkSecondary : AppColors.darkPrimary,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Top Controls (Radius Slider & Filters)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📡 Search Radius: ${_radarRadiusKm.toInt()} km',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Live GPS Active', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radarRadiusKm,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    activeColor: AppColors.darkSecondary,
                    onChanged: (val) {
                      setState(() {
                        _radarRadiusKm = val;
                      });
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _types.map((type) {
                        final isSel = _selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(type, style: const TextStyle(fontSize: 11)),
                            selected: isSel,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Preview Card
          if (_selectedEvent != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedEvent!.bannerUrl,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 75,
                          height: 75,
                          color: AppColors.darkSurfaceElevated,
                          child: const Icon(Iconsax.calendar_2),
                        ),
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
                                  color: AppColors.darkPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedEvent!.category,
                                  style: const TextStyle(fontSize: 9, color: AppColors.darkPrimary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedEvent!.cityName,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedEvent!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedEvent!.venueName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/event-detail',
                          arguments: _selectedEvent,
                        );
                      },
                      child: const Text('Details', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

