import 'dart:math' as math;
import '../../domain/entities/event_entity.dart';

abstract class EventCalendarState {
  const EventCalendarState();
}

class EventLoading extends EventCalendarState {
  const EventLoading();
}

class EventLoaded extends EventCalendarState {
  final List<EventEntity> allEvents;
  final String selectedCity;
  final double selectedRadiusKm;

  // User's GPS coordinates — null means location not yet obtained
  final double? userLatitude;
  final double? userLongitude;

  const EventLoaded({
    required this.allEvents,
    this.selectedCity = 'All Cities',
    this.selectedRadiusKm = 100.0,
    this.userLatitude,
    this.userLongitude,
  });

  // ── Haversine formula: distance between two lat/lng points in km ──────────
  static double _haversineKm(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const r = 6371.0; // Earth radius km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;

  /// Returns events filtered by city. When user GPS coordinates are present
  /// AND city is 'All Cities', applies radius-based filtering instead.
  List<EventEntity> get filteredEvents {
    // GPS radius filter: only when user location is known and no city selected
    if (userLatitude != null &&
        userLongitude != null &&
        selectedCity == 'All Cities') {
      return allEvents.where((e) {
        final dist = _haversineKm(
          userLatitude!, userLongitude!,
          e.latitude, e.longitude,
        );
        return dist <= selectedRadiusKm;
      }).toList();
    }

    // City filter (existing behaviour)
    if (selectedCity == 'All Cities') return allEvents;
    return allEvents
        .where((e) =>
            e.cityName.toLowerCase() == selectedCity.toLowerCase())
        .toList();
  }

  List<EventEntity> get bookmarkedEvents {
    return allEvents.where((e) => e.isBookmarked).toList();
  }

  /// Distance from user to a specific event (null if location unknown)
  double? distanceTo(EventEntity event) {
    if (userLatitude == null || userLongitude == null) return null;
    return _haversineKm(
      userLatitude!, userLongitude!,
      event.latitude, event.longitude,
    );
  }

  EventLoaded copyWith({
    List<EventEntity>? allEvents,
    String? selectedCity,
    double? selectedRadiusKm,
    double? userLatitude,
    double? userLongitude,
    bool clearUserLocation = false,
  }) {
    return EventLoaded(
      allEvents: allEvents ?? this.allEvents,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedRadiusKm: selectedRadiusKm ?? this.selectedRadiusKm,
      userLatitude: clearUserLocation ? null : (userLatitude ?? this.userLatitude),
      userLongitude: clearUserLocation ? null : (userLongitude ?? this.userLongitude),
    );
  }
}

class EventError extends EventCalendarState {
  final String message;
  const EventError(this.message);
}
