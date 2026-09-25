import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String cityName;
  final String venueName;
  final double latitude;
  final double longitude;
  final DateTime eventDate;
  final String ticketLink;
  final String bannerUrl;
  final String category;
  final int attendeesCount;
  final bool isBookmarked;
  final bool isRsvped;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.cityName,
    required this.venueName,
    required this.latitude,
    required this.longitude,
    required this.eventDate,
    required this.ticketLink,
    required this.bannerUrl,
    required this.category,
    this.attendeesCount = 120,
    this.isBookmarked = false,
    this.isRsvped = false,
  });

  EventEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? cityName,
    String? venueName,
    double? latitude,
    double? longitude,
    DateTime? eventDate,
    String? ticketLink,
    String? bannerUrl,
    String? category,
    int? attendeesCount,
    bool? isBookmarked,
    bool? isRsvped,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cityName: cityName ?? this.cityName,
      venueName: venueName ?? this.venueName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDate: eventDate ?? this.eventDate,
      ticketLink: ticketLink ?? this.ticketLink,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      category: category ?? this.category,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isRsvped: isRsvped ?? this.isRsvped,
    );
  }

  factory EventEntity.fromDbMap(Map<String, dynamic> map) {
    return EventEntity(
      id: (map['event_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      cityName: (map['city_name'] ?? '').toString(),
      venueName: (map['venue_name'] ?? '').toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      eventDate: DateTime.fromMillisecondsSinceEpoch((map['event_date'] as num?)?.toInt() ?? 0),
      ticketLink: (map['ticket_link'] ?? '').toString(),
      bannerUrl: (map['banner_url'] ?? '').toString(),
      category: (map['category'] ?? 'Convention').toString(),
      attendeesCount: (map['attendees_count'] as num?)?.toInt() ?? 120,
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
      isRsvped: (map['is_rsvped'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'event_id': id,
      'title': title,
      'description': description,
      'city_name': cityName,
      'venue_name': venueName,
      'latitude': latitude,
      'longitude': longitude,
      'event_date': eventDate.millisecondsSinceEpoch,
      'ticket_link': ticketLink,
      'banner_url': bannerUrl,
      'category': category,
      'attendees_count': attendeesCount,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'is_rsvped': isRsvped ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        cityName,
        venueName,
        latitude,
        longitude,
        eventDate,
        ticketLink,
        bannerUrl,
        category,
        attendeesCount,
        isBookmarked,
        isRsvped,
      ];
}
