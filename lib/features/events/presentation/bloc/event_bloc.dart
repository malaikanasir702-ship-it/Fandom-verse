import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/event_mock_data.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventCalendarBloc extends Bloc<EventCalendarEvent, EventCalendarState> {
  EventCalendarBloc() : super(const EventLoading()) {
    on<LoadAllEventsEvent>(_onLoadEvents);
    on<FilterEventsByCityEvent>(_onFilterByCity);
    on<FilterEventsByRadiusEvent>(_onFilterByRadius);
    on<ToggleEventBookmarkEvent>(_onToggleBookmark);
    on<ToggleEventRsvpEvent>(_onToggleRsvp);
  }

  void _onLoadEvents(
    LoadAllEventsEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    emit(EventLoaded(allEvents: EventMockData.sampleEvents));
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

  void _onToggleBookmark(
    ToggleEventBookmarkEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      final updatedList = current.allEvents.map((item) {
        if (item.id == event.eventId) {
          return item.copyWith(isBookmarked: !item.isBookmarked);
        }
        return item;
      }).toList();
      emit(current.copyWith(allEvents: updatedList));
    }
  }

  void _onToggleRsvp(
    ToggleEventRsvpEvent event,
    Emitter<EventCalendarState> emit,
  ) {
    if (state is EventLoaded) {
      final current = state as EventLoaded;
      final updatedList = current.allEvents.map((item) {
        if (item.id == event.eventId) {
          final newRsvp = !item.isRsvped;
          return item.copyWith(
            isRsvped: newRsvp,
            attendeesCount: newRsvp ? item.attendeesCount + 1 : item.attendeesCount - 1,
          );
        }
        return item;
      }).toList();
      emit(current.copyWith(allEvents: updatedList));
    }
  }
}
