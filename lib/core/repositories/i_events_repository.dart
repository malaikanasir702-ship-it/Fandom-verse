import '../../features/events/domain/entities/event_entity.dart';

abstract class IEventsRepository {
  Future<List<EventEntity>> getAllEvents();
  Future<void> toggleBookmark(String eventId, bool isBookmarked);
  Future<void> toggleRsvp(String eventId, bool isRsvped, int attendeesCount);
}
