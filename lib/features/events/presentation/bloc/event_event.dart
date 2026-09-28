abstract class EventCalendarEvent {
  const EventCalendarEvent();
}

class LoadAllEventsEvent extends EventCalendarEvent {
  const LoadAllEventsEvent();
}

class FilterEventsByCityEvent extends EventCalendarEvent {
  final String cityName;
  const FilterEventsByCityEvent(this.cityName);
}

class FilterEventsByRadiusEvent extends EventCalendarEvent {
  final double radiusKm;
  const FilterEventsByRadiusEvent(this.radiusKm);
}

/// Dispatched after GPS coordinates are obtained via geolocator.
/// Updates the bloc state with the user's current position so
/// radius-based filtering in [EventLoaded.filteredEvents] works correctly.
class UpdateUserLocationEvent extends EventCalendarEvent {
  final double latitude;
  final double longitude;
  const UpdateUserLocationEvent({
    required this.latitude,
    required this.longitude,
  });
}

class ToggleEventBookmarkEvent extends EventCalendarEvent {
  final String eventId;
  const ToggleEventBookmarkEvent(this.eventId);
}

class ToggleEventRsvpEvent extends EventCalendarEvent {
  final String eventId;
  const ToggleEventRsvpEvent(this.eventId);
}
