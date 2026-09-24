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

class ToggleEventBookmarkEvent extends EventCalendarEvent {
  final String eventId;
  const ToggleEventBookmarkEvent(this.eventId);
}

class ToggleEventRsvpEvent extends EventCalendarEvent {
  final String eventId;
  const ToggleEventRsvpEvent(this.eventId);
}
