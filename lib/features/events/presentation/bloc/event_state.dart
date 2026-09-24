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

  const EventLoaded({
    required this.allEvents,
    this.selectedCity = 'All Cities',
    this.selectedRadiusKm = 100.0,
  });

  List<EventEntity> get filteredEvents {
    if (selectedCity == 'All Cities') {
      return allEvents;
    }
    return allEvents.where((e) => e.cityName.toLowerCase() == selectedCity.toLowerCase()).toList();
  }

  List<EventEntity> get bookmarkedEvents {
    return allEvents.where((e) => e.isBookmarked).toList();
  }

  EventLoaded copyWith({
    List<EventEntity>? allEvents,
    String? selectedCity,
    double? selectedRadiusKm,
  }) {
    return EventLoaded(
      allEvents: allEvents ?? this.allEvents,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedRadiusKm: selectedRadiusKm ?? this.selectedRadiusKm,
    );
  }
}

class EventError extends EventCalendarState {
  final String message;
  const EventError(this.message);
}
