class EventEntity {
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
}
