import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../domain/entities/event_entity.dart';
import '../../presentation/bloc/event_bloc.dart';
import '../../presentation/bloc/event_event.dart';
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

  // GPS location state
  bool _locationEnabled = false;
  bool _locationLoading = false;

  List<EventEntity> _filteredByType(List<EventEntity> events) {
    if (_selectedType == 'All') return events;
    return events
        .where((e) =>
            e.category.toLowerCase().contains(_selectedType.toLowerCase()))
        .toList();
  }

  Future<void> _addMarkers(List<EventEntity> events) async {
    final ctrl = _mapController;
    if (ctrl == null) return;

    for (final sym in _symbols) {
      try {
        await ctrl.removeSymbol(sym);
      } catch (_) {}
    }
    _symbols.clear();

    for (final event in events) {
      final isSelected = event.id == _selectedEvent?.id;
      final sym = await ctrl.addSymbol(
        SymbolOptions(
          geometry: LatLng(event.latitude, event.longitude),
          iconImage: 'marker-15',
          iconSize: isSelected ? 2.8 : 2.0,
          iconColor: isSelected ? '#FFD700' : '#E53935',
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

  /// Request device GPS coordinates using geolocator, then dispatch
  /// [UpdateUserLocationEvent] to the bloc so radius filter becomes active.
  Future<void> _requestUserLocation() async {
    if (_locationLoading) return;
    setState(() => _locationLoading = true);

    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(
          'Location services are disabled. Enable GPS in device Settings.',
        );
        return;
      }

      // 2. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError(
            'Location permission denied. Allow it in Settings → App → Permissions.',
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
          'Location permission permanently denied. Enable it in App Settings.',
        );
        return;
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 4. Update bloc with real coordinates → triggers radius filter
      if (mounted) {
        context.read<EventCalendarBloc>().add(
              UpdateUserLocationEvent(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
        // Also dispatch current radius to bloc
        context.read<EventCalendarBloc>().add(
              FilterEventsByRadiusEvent(_radarRadiusKm),
            );
      }

      // 5. Enable the blue-dot on the MapLibre map
      final ctrl = _mapController;
      if (ctrl != null) {
        await ctrl.updateMyLocationTrackingMode(
          MyLocationTrackingMode.trackingGps,
        );
        // Fly map to user position
        ctrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 5,
            ),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _locationEnabled = true;
        _locationLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📍 Location found! Showing events within ${_radarRadiusKm.toInt()} km.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } on PlatformException catch (e) {
      _showLocationError(
        e.code == 'PERMISSION_DENIED'
            ? 'Location permission denied. Enable it in Settings.'
            : 'Could not get GPS: ${e.message}',
      );
    } catch (e) {
      _showLocationError(
        'Location unavailable. Make sure GPS is on.',
      );
    }
  }

  void _showLocationError(String msg) {
    if (!mounted) return;
    setState(() => _locationLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onStyleLoaded(List<EventEntity> events) async {
    final filtered = _filteredByType(events);
    await _addMarkers(filtered);
    _fitBounds(filtered);
  }

  void _onSymbolTapped(Symbol symbol) {
    final s = context.read<EventCalendarBloc>().state;
    if (s is! EventLoaded) return;
    final filtered = _filteredByType(s.filteredEvents);
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
        final loaded = state is EventLoaded ? state : null;
        final allEvents = loaded?.allEvents ?? <EventEntity>[];
        // Use bloc's filteredEvents (has radius + city logic)
        final filtered = _filteredByType(loaded?.filteredEvents ?? allEvents);

        if (_selectedEvent == null && filtered.isNotEmpty) {
          _selectedEvent = filtered.first;
        }
        // If selected event got filtered out, clear it
        if (_selectedEvent != null &&
            !filtered.any((e) => e.id == _selectedEvent!.id)) {
          _selectedEvent = filtered.isNotEmpty ? filtered.first : null;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Radar Map',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              // GPS Near Me button
              IconButton(
                tooltip: _locationEnabled ? 'Location Active' : 'Show My Location',
                icon: _locationLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.darkSecondary,
                        ),
                      )
                    : Icon(
                        _locationEnabled
                            ? Iconsax.location_tick
                            : Iconsax.location,
                        color: _locationEnabled ? AppColors.darkSecondary : null,
                      ),
                onPressed: _locationLoading ? null : _requestUserLocation,
              ),
              IconButton(
                tooltip: 'Fit All Events',
                icon: const Icon(Iconsax.maximize_3),
                onPressed: () => _fitBounds(filtered),
              ),
            ],
          ),
          body: Stack(
            children: [
              // ── MapLibre GL Map ──────────────────────────────────────────
              MapLibreMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: () => _onStyleLoaded(allEvents),
                styleString: 'https://demotiles.maplibre.org/style.json',
                initialCameraPosition: const CameraPosition(
                  target: LatLng(25.0, 30.0),
                  zoom: 1.5,
                ),
                compassEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                myLocationEnabled: true,
                myLocationTrackingMode: _locationEnabled
                    ? MyLocationTrackingMode.trackingGps
                    : MyLocationTrackingMode.none,
                myLocationRenderMode: MyLocationRenderMode.compass,
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
                          Row(
                            children: [
                              const Text(
                                '📡 Radius: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                '${_radarRadiusKm.toInt()} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: AppColors.darkSecondary,
                                ),
                              ),
                              // Show radius-filter active badge
                              if (_locationEnabled) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'GPS Active',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              // GPS Near Me chip
                              GestureDetector(
                                onTap: _locationLoading
                                    ? null
                                    : _requestUserLocation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _locationEnabled
                                        ? AppColors.darkSecondary
                                            .withValues(alpha: 0.15)
                                        : AppColors.comicRed
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _locationEnabled
                                          ? AppColors.darkSecondary
                                          : AppColors.comicRed,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _locationEnabled
                                            ? Iconsax.location_tick
                                            : Iconsax.location,
                                        size: 12,
                                        color: _locationEnabled
                                            ? AppColors.darkSecondary
                                            : AppColors.comicRed,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _locationEnabled ? 'GPS On' : 'Near Me',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _locationEnabled
                                              ? AppColors.darkSecondary
                                              : AppColors.comicRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.15),
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
                        ],
                      ),

                      // ── Radius Slider — now functional ──────────────────
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
                          max: 10000,
                          divisions: 99,
                          onChanged: (val) {
                            setState(() => _radarRadiusKm = val);
                          },
                          onChangeEnd: (val) {
                            // Dispatch to bloc when user releases slider
                            context.read<EventCalendarBloc>().add(
                                  FilterEventsByRadiusEvent(val),
                                );
                            // Re-draw markers with new filter
                            final s =
                                context.read<EventCalendarBloc>().state;
                            if (s is EventLoaded) {
                              final newFiltered = _filteredByType(
                                s.filteredEvents,
                              );
                              _addMarkers(newFiltered);
                              _fitBounds(newFiltered);
                            }
                          },
                        ),
                      ),

                      // ── Category Filter Chips ───────────────────────────
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
                                final s =
                                    context.read<EventCalendarBloc>().state;
                                if (s is EventLoaded) {
                                  final newFiltered = _filteredByType(
                                      s.filteredEvents);
                                  await _addMarkers(newFiltered);
                                  _fitBounds(newFiltered);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Selected Event Card ─────────────────────────────
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
                          child: CachedNetworkImage(
                            imageUrl: _selectedEvent!.bannerUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.darkSurfaceElevated,
                              child: const Icon(Iconsax.calendar_2),
                            ),
                            errorWidget: (_, __, ___) => Container(
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
                                style: AppTextStyles.titleMedium
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              // Show distance if GPS active
                              if (_locationEnabled && loaded != null)
                                Builder(builder: (_) {
                                  final dist =
                                      loaded.distanceTo(_selectedEvent!);
                                  if (dist == null) return const SizedBox.shrink();
                                  return Row(
                                    children: [
                                      const Icon(Iconsax.location,
                                          size: 11,
                                          color: AppColors.darkSecondary),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${dist.toStringAsFixed(0)} km away',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.darkSecondary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  );
                                })
                              else
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

              // ── Floating event count badge ──────────────────────────────
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
