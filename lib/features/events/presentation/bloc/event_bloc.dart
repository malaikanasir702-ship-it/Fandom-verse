import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/i_events_repository.dart';
import '../../../../core/repositories/events_repository_impl.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventCalendarBloc extends Bloc<EventCalendarEvent, EventCalendarState> {
  final IEventsRepository _repository;

  EventCalendarBloc({IEventsRepository? repository})
      : _repository = repository ?? EventsRepositoryImpl(),
        super(const EventLoading()) {
    on<LoadAllEventsEvent>(_onLoadEvents);
    on<FilterEventsByCityEvent>(_onFilterByCity);
    on<FilterEventsByRadiusEvent>(_onFilterByRadius);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<ToggleEventBookmarkEvent>(_onToggleBookmark);
    on<ToggleEventRsvpEvent>(_onToggleRsvp);
  }

  Future<void> _onLoadEvents(
    LoadAllEventsEvent event,
    Emitter<EventCalendarState> emit,
  ) async {
    emit(const EventLoading());
    try {
      final events = await _repository.getAllEvents();
      emit(EventLoaded(allEvents: events));
    } catch (_) {
      emit(const EventLoaded(allEvents: []));
    }
  }

  void _onFilterByCity(
    FilterEventsByCityEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      emit(current.copyWith(selectedCity: event.cityName));
    }
  }

  void _onFilterByRadius(
    FilterEventsByRadiusEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      emit(current.copyWith(selectedRadiusKm: event.radiusKm));
    }
  }

  /// Stores the user's GPS coordinates in state. Once set, [EventLoaded.filteredEvents]
  /// automatically applies the haversine radius filter when 'All Cities' is selected.
  void _onUpdateUserLocation(
    UpdateUserLocationEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      emit(current.copyWith(
        userLatitude: event.latitude,
        userLongitude: event.longitude,
        // Switch to 'All Cities' so radius filter takes effect immediately
        selectedCity: 'All Cities',
      ));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleEventBookmarkEvent event,
    Emitter<EventCalendarState> emit,
  ) async {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      bool targetBookmarkState = true;

      final updatedList = current.allEvents.map((item) {
        if (item.id == event.eventId) {
          targetBookmarkState = !item.isBookmarked;
          return item.copyWith(isBookmarked: targetBookmarkState);
        }
        return item;
      }).toList();

      emit(current.copyWith(allEvents: updatedList));

      // Persist to SQLite events table
      await _repository.toggleBookmark(event.eventId, targetBookmarkState);
    }
  }

  Future<void> _onToggleRsvp(
    ToggleEventRsvpEvent event,
    Emitter<EventCalendarState> emit,
  ) async {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      bool newRsvp = false;
      int newAttendeesCount = 0;

      final updatedList = current.allEvents.map((item) {
        if (item.id == event.eventId) {
          newRsvp = !item.isRsvped;
          newAttendeesCount = newRsvp
              ? item.attendeesCount + 1
              : (item.attendeesCount > 0 ? item.attendeesCount - 1 : 0);
          return item.copyWith(
            isRsvped: newRsvp,
            attendeesCount: newAttendeesCount,
          );
        }
        return item;
      }).toList();

      emit(current.copyWith(allEvents: updatedList));

      // Persist to SQLite events table
      await _repository.toggleRsvp(event.eventId, newRsvp, newAttendeesCount);
    }
  }
}
