import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../domain/entities/event_entity.dart';
import '../../presentation/bloc/event_bloc.dart';
import '../../presentation/bloc/event_state.dart';

class EventsMapPage extends StatefulWidget {
  const EventsMapPage({super.key});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  MapLibreMapController? _mapController;
  double _radarRadiusKm = 100.0;
  String _selectedType = 'All';
  EventEntity? _selectedEvent;
  final List<Symbol> _symbols = [];
  final List<String> _types = ['All', 'Anime', 'Comic Con', 'Gaming', 'K-Pop'];

  List<EventEntity> _filteredEvents(List<EventEntity> events) {
    if (_selectedType == 'All') return events;
    return events
        .where((e) =>
            e.category.toLowerCase().contains(_selectedType.toLowerCase()))
        .toList();
  }

  Future<void> _addMarkers(List<EventEntity> events) async {
    final ctrl = _mapController;
    if (ctrl == null) return;

    // Remove old symbols
    for (final sym in _symbols) {
      await ctrl.removeSymbol(sym);
    }
    _symbols.clear();

    for (final event in events) {
      final sym = await ctrl.addSymbol(
        SymbolOptions(
          geometry: LatLng(event.latitude, event.longitude),
          iconImage: 'marker-15',
          iconSize: 2.0,
          iconColor:
              event.id == _selectedEvent?.id ? '#FFD700' : '#E53935',
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

  void _fitBounds(List<EventEntity> events) {
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
        bottom: 220,
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onStyleLoaded(List<EventEntity> events) async {
    final filtered = _filteredEvents(events);
    await _addMarkers(filtered);
    _fitBounds(filtered);
  }

  void _onSymbolTapped(Symbol symbol) {
    final state = context.read<EventCalendarBloc>().state;
    if (state is! EventLoaded) return;
    final filtered = _filteredEvents(state.allEvents);
    final idx = _symbols.indexOf(symbol);
    if (idx >= 0 && idx < filtered.length) {
      final event = filtered[idx];
      setState(() => _selectedEvent = event);
      _flyToEvent(event);
      _addMarkers(filtered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<EventCalendarBloc, EventCalendarState>(
      builder: (context, state) {
        final allEvents =
            state is EventLoaded ? state.allEvents : <EventEntity>[];
        final filtered = _filteredEvents(allEvents);

        if (_selectedEvent == null && filtered.isNotEmpty) {
          _selectedEvent = filtered.first;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Radar Map',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                tooltip: 'Fit All Events',
                icon: const Icon(Iconsax.maximize_3),
                onPressed: () => _fitBounds(filtered),
              ),
              IconButton(
                tooltip: 'Center on First Event',
                icon: const Icon(Iconsax.location_tick),
                onPressed: () {
                  if (filtered.isNotEmpty) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(filtered.first.latitude,
                            filtered.first.longitude),
                        9,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // ── MapLibre GL Map ──────────────────────────────────────────
              MapLibreMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: () => _onStyleLoaded(allEvents),
                styleString:
                    'https://demotiles.maplibre.org/style.json',
                initialCameraPosition: const CameraPosition(
                  target: LatLng(25.0, 30.0),
                  zoom: 1.5,
                ),
                compassEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                myLocationEnabled: false,
                trackCameraPosition: false,
              ),

              // ── Top Controls ─────────────────────────────────────────────
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: GlassContainer(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              color:
                                  AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${filtered.length} Events',
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.darkSecondary,
                          thumbColor: AppColors.darkSecondary,
                          inactiveTrackColor: AppColors.darkSecondary
                              .withValues(alpha: 0.25),
                          overlayColor: AppColors.darkSecondary
                              .withValues(alpha: 0.15),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: _radarRadiusKm,
                          min: 10,
                          max: 500,
                          divisions: 49,
                          onChanged: (val) =>
                              setState(() => _radarRadiusKm = val),
                        ),
                      ),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _types.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, i) {
                            final type = _types[i];
                            final isSel = _selectedType == type;
                            return ChoiceChip(
                              label: Text(type,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
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
                                final newFiltered =
                                    _filteredEvents(allEvents);
                                await _addMarkers(newFiltered);
                                _fitBounds(newFiltered);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Event Card ────────────────────────────────────────
              if (_selectedEvent != null)
                Positioned(
                  bottom: 20,
                  left: 14,
                  right: 14,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
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
                                      color: AppColors.darkPrimary
                                          .withValues(alpha: 0.18),
                                      borderRadius:
                                          BorderRadius.circular(4),
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
                                  Text(_selectedEvent!.cityName,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedEvent!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Iconsax.location,
                                      size: 11,
                                      color: AppColors.darkSecondary),
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
                                              : AppColors
                                                  .lightTextSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SkewedButton(
                          text: 'Details',
                          height: 44,
                          fontSize: 12,
                          backgroundColor: AppColors.darkPrimary,
                          onPressed: () => Navigator.of(context).pushNamed(
                              '/event-detail',
                              arguments: _selectedEvent),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Event count badge ────────────────────────────────────────
              Positioned(
                bottom: _selectedEvent != null ? 114 : 20,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkSecondary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.darkSecondary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${filtered.length} Events',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
