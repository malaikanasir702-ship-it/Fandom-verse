class AppConstants {
  AppConstants._();

  static const String appName = 'Fandom Verse';
  static const String appSubtitle = 'Pocket Edition — Fandom on the Go';
  static const String appVersion = '1.0.0';

  // Seed Categories
  static const List<String> defaultCategories = [
    'Anime & Manga',
    'Gaming & Esports',
    'Sci-Fi & Fantasy',
    'Marvel & DC Comics',
    'K-Pop & Idol Culture',
    'Pop Culture & Movies',
  ];

  // Starter Badges
  static const List<Map<String, String>> starterBadges = [
    {
      'id': 'novice_otaku',
      'title': 'Novice Otaku',
      'desc': 'Starting the journey through worlds of anime & manga.',
      'icon': '🌟',
    },
    {
      'id': 'lorekeeper',
      'title': 'Lorekeeper',
      'desc': 'Guardian of timelines, hidden trivia & canon secrets.',
      'icon': '📜',
    },
    {
      'id': 'speedrunner',
      'title': 'Speedrunner',
      'desc': 'Master of frame-perfect clears & esports history.',
      'icon': '⚡',
    },
    {
      'id': 'con_veteran',
      'title': 'Con Veteran',
      'desc': 'Cosplayer, attendee & Comic-Con survivor.',
      'icon': '🎟️',
    },
  ];

  // Cities for Event Radar
  static const List<String> popularCities = [
    'All Cities',
    'Tokyo',
    'San Diego',
    'New York',
    'London',
    'Seoul',
    'Karachi',
    'Los Angeles',
  ];
}
