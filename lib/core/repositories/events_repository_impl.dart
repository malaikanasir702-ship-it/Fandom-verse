import '../constants/db_constants.dart';
import '../database/sqlite_helper.dart';
import '../../features/events/domain/entities/event_entity.dart';
import 'i_events_repository.dart';

class EventsRepositoryImpl implements IEventsRepository {
  final SqliteHelper _dbHelper;

  EventsRepositoryImpl({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance;

  @override
  Future<List<EventEntity>> getAllEvents() async {
    final rows = await _dbHelper.query(
      DbConstants.tableEvents,
      orderBy: 'event_date ASC',
    );
    return rows.map((m) => EventEntity.fromDbMap(m)).toList();
  }

  @override
  Future<void> toggleBookmark(String eventId, bool isBookmarked) async {
    await _dbHelper.update(
      DbConstants.tableEvents,
      'event_id',
      eventId,
      {'is_bookmarked': isBookmarked ? 1 : 0},
    );
  }

  @override
  Future<void> toggleRsvp(String eventId, bool isRsvped, int attendeesCount) async {
    await _dbHelper.update(
      DbConstants.tableEvents,
      'event_id',
      eventId,
      {
        'is_rsvped': isRsvped ? 1 : 0,
        'attendees_count': attendeesCount,
      },
    );
  }
}
