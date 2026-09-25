import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
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
  // ── State ──────────────────────────────────────────────────────────────────
  double _radarRadiusKm = 50.0;
  String _selectedType = 'All';
  EventEntity? _selectedEvent;

  MapLibreMapController? _mapController;
  final List<String> _types = ['All', 'Anime', 'Comic Con', 'Gaming', 'K-Pop'];

  // Track symbol IDs so we can clear/re-add on filter change
  final List<Symbol> _symbols = [];

  @override
  void initState() {
    super.initState();
    if (EventMockData.events.isNotEmpty) {
      _selectedEvent = EventMockData.events.first;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<EventEntity> get _filteredEvents => EventMockData.events.where((e) {
        if (_selectedType == 'All') return true;
        return e.category.toLowerCase().contains(_selectedType.toLowerCase());
      }).toList();

  /// Add circle markers for every filtered event onto the map.
  Future<void> _addMarkers() async {
    final ctrl = _mapController;
    if (ctrl == null) return;

    // Remove old symbols
    for (final sym in _symbols) {
      await ctrl.removeSymbol(sym);
    }
    _symbols.clear();

    for (final event in _filteredEvents) {
      final sym = await ctrl.addSymbol(
        SymbolOptions(
          geometry: LatLng(event.latitude, event.longitude),
          iconImage: 'marker-15',
          iconSize: 2.0,
          iconColor: event.id == _selectedEvent?.id ? '#FFD700' : '#E53935',
          textField: event.cityName,
          textSize: 11,
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 1.5,
          textOffset: const Offset(0, 1.8),
        ),
      );
      _symbols.add(sym);
    }
  }

  /// Fly the camera to the selected event location.
  void _flyToEvent(EventEntity event) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(event.latitude, event.longitude),
          zoom: 10,
          tilt: 30,
        ),
      ),
    );
  }

  /// Fit the camera to show all filtered markers.
  void _fitBounds() {
    final events = _filteredEvents;
    if (events.isEmpty || _mapController == null) return;

    if (events.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(events.first.latitude, events.first.longitude),
          8,
        ),
      );
      return;
    }

    double minLat = events.first.latitude;
    double maxLat = events.first.latitude;
    double minLng = events.first.longitude;
    double maxLng = events.first.longitude;

    for (final e in events) {
      if (e.latitude < minLat) minLat = e.latitude;
      if (e.latitude > maxLat) maxLat = e.latitude;
      if (e.longitude < minLng) minLng = e.longitude;
      if (e.longitude > maxLng) maxLng = e.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 2, minLng - 2),
          northeast: LatLng(maxLat + 2, maxLng + 2),
        ),
        left: 60,
        top: 180,
        right: 60,
        bottom: 200,
      ),
    );
  }

  // ── Map callbacks ──────────────────────────────────────────────────────────

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onStyleLoaded() async {
    await _addMarkers();
    _fitBounds();
  }

  void _onSymbolTapped(Symbol symbol) {
    // Find which event corresponds to this symbol index
    final idx = _symbols.indexOf(symbol);
    if (idx >= 0 && idx < _filteredEvents.length) {
      final event = _filteredEvents[idx];
      setState(() => _selectedEvent = event);
      _flyToEvent(event);
      // Refresh markers to update selected highlight color
      _addMarkers();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Radar Map',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          // Fit-all button
          IconButton(
            tooltip: 'Fit All Events',
            icon: const Icon(Iconsax.maximize_3),
            onPressed: () {
              _fitBounds();
            },
          ),
          // Re-center on first event (simulates GPS)
          IconButton(
            tooltip: 'My Location',
            icon: const Icon(Iconsax.location_tick),
            onPressed: () {
              final first = _filteredEvents.isNotEmpty
                  ? _filteredEvents.first
                  : null;
              if (first != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(first.latitude, first.longitude),
                    9,
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 Centered on nearest event location'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── MapLibre GL Map ──────────────────────────────────────────────
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            styleString:
                'https://demotiles.maplibre.org/style.json', // free tile style
            initialCameraPosition: const CameraPosition(
              target: LatLng(25.0, 30.0), // roughly world center
              zoom: 1.5,
            ),
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationEnabled: false, // skip runtime permission for now
            trackCameraPosition: false,
          ),

          // ── Top Controls: Radius Slider + Category Filter ────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: GlassContainer(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Radius row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📡 Radius: ${_radarRadiusKm.toInt()} km',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Live GPS Active',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.darkSecondary,
                      thumbColor: AppColors.darkSecondary,
                      inactiveTrackColor:
                          AppColors.darkSecondary.withValues(alpha: 0.25),
                      overlayColor:
                          AppColors.darkSecondary.withValues(alpha: 0.15),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _radarRadiusKm,
                      min: 10,
                      max: 500,
                      divisions: 49,
                      onChanged: (val) {
                        setState(() => _radarRadiusKm = val);
                      },
                    ),
                  ),
                  // Category chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _types.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, i) {
                        final type = _types[i];
                        final isSel = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          selected: isSel,
                          selectedColor: AppColors.darkSecondary,
                          labelStyle: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                          onSelected: (_) async {
                            setState(() => _selectedType = type);
                            await _addMarkers();
                            _fitBounds();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Event Preview Card ─────────────────────────────────────
          if (_selectedEvent != null)
            Positioned(
              bottom: 20,
              left: 14,
              right: 14,
              child: GlassContainer(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedEvent!.bannerUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.darkSurfaceElevated,
                          child: const Icon(Iconsax.calendar_2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.darkPrimary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedEvent!.category,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.darkPrimary,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedEvent!.cityName,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedEvent!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Iconsax.location,
                                  size: 11, color: AppColors.darkSecondary),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  _selectedEvent!.venueName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Details button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/event-detail',
                          arguments: _selectedEvent,
                        );
                      },
                      child: const Text('Details',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

          // ── Event count badge ─────────────────────────────────────────────
          Positioned(
            bottom: _selectedEvent != null ? 114 : 20,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkSecondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkSecondary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${_filteredEvents.length} Events',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
