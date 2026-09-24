import '../domain/entities/event_entity.dart';

class EventMockData {
  EventMockData._();

  static List<EventEntity> get events => sampleEvents;

  static final List<EventEntity> sampleEvents = [
    EventEntity(
      id: 'ev-01',
      title: 'Anime Expo & Cosplay Championship 2025',
      description:
          'The largest celebration of Japanese pop culture in North America. Features guest voice actors, industry world premieres, artist alley, and the World Cosplay Summit finals.',
      cityName: 'Los Angeles',
      venueName: 'Los Angeles Convention Center, CA',
      latitude: 34.0407,
      longitude: -118.2695,
      eventDate: DateTime.now().add(const Duration(days: 14)),
      ticketLink: 'https://www.anime-expo.org',
      bannerUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      category: 'Anime & Manga',
      attendeesCount: 110000,
    ),
    EventEntity(
      id: 'ev-02',
      title: 'San Diego Comic-Con International',
      description:
          'The epicenter of comic culture, superhero cinematic reveals, Hall H star panels, and exclusive collectible drops.',
      cityName: 'San Diego',
      venueName: 'San Diego Convention Center, CA',
      latitude: 32.7071,
      longitude: -117.1627,
      eventDate: DateTime.now().add(const Duration(days: 35)),
      ticketLink: 'https://www.comic-con.org',
      bannerUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      category: 'Marvel & DC Comics',
      attendeesCount: 135000,
    ),
    EventEntity(
      id: 'ev-03',
      title: 'Tokyo Game Show (TGS) 2025',
      description:
          'Experience the next generation of AAA RPGs, indie showcases, VR innovations, and Japanese gaming culture straight from Makuhari Messe.',
      cityName: 'Tokyo',
      venueName: 'Makuhari Messe, Chiba, Japan',
      latitude: 35.6481,
      longitude: 140.0347,
      eventDate: DateTime.now().add(const Duration(days: 48)),
      ticketLink: 'https://tgs.nikkeibp.co.jp',
      bannerUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
      category: 'Gaming & Esports',
      attendeesCount: 240000,
    ),
    EventEntity(
      id: 'ev-04',
      title: 'MCM London Comic Con & Pop Summit',
      description:
          'The UK\'s premier pop culture weekend featuring British sci-fi icons, gaming stages, cosplay masquerades, and fan merchandise pavilions.',
      cityName: 'London',
      venueName: 'ExCeL London, United Kingdom',
      latitude: 51.5076,
      longitude: 0.0305,
      eventDate: DateTime.now().add(const Duration(days: 62)),
      ticketLink: 'https://www.mcmcomiccon.com',
      bannerUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
      category: 'Pop Culture & Movies',
      attendeesCount: 88000,
    ),
    EventEntity(
      id: 'ev-05',
      title: 'Seoul K-Pop Idol Awards & Fandom Con',
      description:
          'A star-studded weekend combining global fandom fan-meetings, lightstick synchronization rallies, idol choreography workshops, and the grand music gala.',
      cityName: 'Seoul',
      venueName: 'Gocheok Sky Dome, Seoul, South Korea',
      latitude: 37.4982,
      longitude: 126.8671,
      eventDate: DateTime.now().add(const Duration(days: 21)),
      ticketLink: 'https://kpopawards.kr',
      bannerUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      category: 'K-Pop & Idol Culture',
      attendeesCount: 45000,
    ),
    EventEntity(
      id: 'ev-06',
      title: 'Karachi Anime & Gaming Con (KGC 2025)',
      description:
          'South Asia\'s fastest growing gaming and anime festival featuring Tekken 8 pro invitationals, artist alleys, cosplay runway, and retro arcade arenas.',
      cityName: 'Karachi',
      venueName: 'Expo Center Karachi, University Road',
      latitude: 24.9180,
      longitude: 67.0971,
      eventDate: DateTime.now().add(const Duration(days: 18)),
      ticketLink: 'https://kgc.fandomverse.pk',
      bannerUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
      category: 'Gaming & Esports',
      attendeesCount: 15000,
    ),
  ];
}
