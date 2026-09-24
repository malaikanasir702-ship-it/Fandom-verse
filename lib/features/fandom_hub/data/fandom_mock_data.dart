import '../domain/entities/fandom_post.dart';
import '../domain/entities/glossary_term.dart';

class FandomMockData {
  FandomMockData._();

  static final List<FandomPost> trendingBanners = [
    FandomPost(
      id: 'trend-01',
      category: 'Anime & Manga',
      title: 'Solo Leveling: Arise & The Monarch Wars Canon Explained',
      contentBody:
          'From the shadows of the Double Dungeon to the awakening of Sung Jin-woo as the Shadow Monarch, discover how the universe lore bridges the gap between webtoon and animation.',
      authorName: 'Kenji Sato',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      isTrending: true,
      readTimeMinutes: 5,
      tags: ['Anime', 'Monarchs', 'Lore'],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FandomPost(
      id: 'trend-02',
      category: 'Gaming & Esports',
      title: 'Elden Ring Shadow of the Erdtree: Miquella Lore Breakdown',
      contentBody:
          'A deep analytical journey into the Land of Shadow, exploring Saint Trina, Messmer the Impaler, and the ancient divine gate of Enir-Ilim.',
      authorName: 'Elena Rostova',
      imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800',
      isTrending: true,
      readTimeMinutes: 8,
      tags: ['Elden Ring', 'FromSoftware', 'Deep Lore'],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FandomPost(
      id: 'trend-03',
      category: 'Sci-Fi & Fantasy',
      title: 'Dune Messiah: Paul Atreides & The Jihad Consequences',
      contentBody:
          'Exploring Frank Herbert\'s thematic masterstroke: how prescience becomes a prison and why the Golden Path demands supreme sacrifice.',
      authorName: 'David Thorne',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800',
      isTrending: true,
      readTimeMinutes: 6,
      tags: ['Dune', 'SciFi', 'Cinema'],
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    FandomPost(
      id: 'trend-04',
      category: 'Marvel & DC Comics',
      title: 'Secret Wars & The Multiverse Collapse: Comic Timeline Primer',
      contentBody:
          'Before the MCU adapts Secret Wars, revisit Jonathan Hickman\'s 2015 saga where Doctor Doom created Battleworld out of dying realities.',
      authorName: 'Marcus Vance',
      imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      isTrending: true,
      readTimeMinutes: 7,
      tags: ['Marvel', 'Comics', 'Multiverse'],
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
    ),
  ];

  static final List<FandomPost> latestNews = [
    FandomPost(
      id: 'news-01',
      category: 'Anime & Manga',
      title: 'Chainsaw Man Reze Arc Movie Confirms Worldwide Theatrical Release',
      contentBody:
          'MAPPA studio unveils high-octane explosive teaser trailer featuring Denji and the Bomb Devil in a romantic yet lethal rendezvous across Tokyo.',
      authorName: 'Akira Tanaka',
      imageUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=600',
      readTimeMinutes: 3,
      tags: ['Chainsaw Man', 'MAPPA', 'Movie'],
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    FandomPost(
      id: 'news-02',
      category: 'Gaming & Esports',
      title: 'Worlds 2025 Grand Finals Announced for London O2 Arena',
      contentBody:
          'Riot Games confirms the premier League of Legends championship will return to Europe featuring the top 16 regional champions.',
      authorName: 'Sarah Jenkins',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      readTimeMinutes: 4,
      tags: ['Esports', 'LoL', 'Tournament'],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    FandomPost(
      id: 'news-03',
      category: 'K-Pop & Idol Culture',
      title: 'Stray Kids Shatters Stadium Attendance Records Across Asia Leg',
      contentBody:
          'The 8-member self-producing juggernaut wraps up historic stadium dates with bespoke orchestral arrangements of God\'s Menu and MANIAC.',
      authorName: 'Min-ho Park',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
      readTimeMinutes: 3,
      tags: ['K-Pop', 'Stray Kids', 'Concert'],
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    FandomPost(
      id: 'news-04',
      category: 'Pop Culture & Movies',
      title: 'Grand Admiral Thrawn Return Sets Stage for The Mandalorian Climax',
      contentBody:
          'Lucasfilm reveals production blueprints for Dave Filoni\'s upcoming theatrical feature weaving together Ahsoka, Din Djarin, and Imperial remnants.',
      authorName: 'Liam O\'Connor',
      imageUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
      readTimeMinutes: 5,
      tags: ['Star Wars', 'Mandalorian', 'Thrawn'],
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  static final List<GlossaryTerm> glossaryList = [
    GlossaryTerm(
      id: 'gl-01',
      term: 'Canon',
      phonetic: '/ˈkæn.ən/',
      fandomCategory: 'Pop Culture & Movies',
      definition:
          'The official, authoritative storyline, events, and character arcs recognized as true within a fictional universe by its original creators.',
      exampleUsage:
          'The Expanded Universe novels were declared "Legends", making only the six films and Clone Wars canon in 2014.',
    ),
    GlossaryTerm(
      id: 'gl-02',
      term: 'Isekai',
      phonetic: '/iː.seɪˈkaɪ/',
      fandomCategory: 'Anime & Manga',
      definition:
          'A Japanese genre of fantasy where a protagonist is suddenly transported, summoned, or reincarnated into a parallel or video game world.',
      exampleUsage:
          'That Time I Got Reincarnated as a Slime is one of the pinnacle modern Isekai light novels.',
    ),
    GlossaryTerm(
      id: 'gl-03',
      term: 'Speedrun Any%',
      phonetic: '/ˈspiːd.rʌn ˈɛni pərˈsɛnt/',
      fandomCategory: 'Gaming & Esports',
      definition:
          'A competitive gaming category where the player attempts to reach the final credits roll as fast as possible, using any glitches or sequence breaks allowed.',
      exampleUsage:
          'The current Any% world record for Breath of the Wild sits under 24 minutes thanks to shield clipping.',
    ),
    GlossaryTerm(
      id: 'gl-04',
      term: 'Waifu / Husbando',
      phonetic: '/ˈwaɪ.fuː/',
      fandomCategory: 'Anime & Manga',
      definition:
          'A fictional character from anime, manga, or video games that a fan has affectionate, devoted admiration for as an ideal partner.',
      exampleUsage:
          'Her room was decorated with tapestries of her favorite waifu, Yor Forger.',
    ),
    GlossaryTerm(
      id: 'gl-05',
      term: 'Retcon',
      phonetic: '/ˈrɛt.kɒn/',
      fandomCategory: 'Marvel & DC Comics',
      definition:
          'Short for "Retroactive Continuity". A literary device where previously established facts in a fictional universe are altered or ignored by later works.',
      exampleUsage:
          'The revelation that Bucky Barnes survived and became the Winter Soldier was a masterclass comic retcon.',
    ),
    GlossaryTerm(
      id: 'gl-06',
      term: 'Stan',
      phonetic: '/stæn/',
      fandomCategory: 'K-Pop & Idol Culture',
      definition:
          'An intensely enthusiastic, loyal, and supportive fan of a particular idol, music group, or pop icon.',
      exampleUsage:
          'I have been an active BTS stan since their 2015 HYYH era.',
    ),
    GlossaryTerm(
      id: 'gl-07',
      term: 'Filler',
      phonetic: '/ˈfɪl.ər/',
      fandomCategory: 'Anime & Manga',
      definition:
          'Anime episodes or entire arcs not adapted from the original manga, usually produced so the manga author can write more material ahead.',
      exampleUsage:
          'Naruto Shippuden features over 40% filler episodes, including the famous mecha Naruto special.',
    ),
    GlossaryTerm(
      id: 'gl-08',
      term: 'Cosplay',
      phonetic: '/ˈkɒz.pleɪ/',
      fandomCategory: 'Pop Culture & Movies',
      definition:
          'A portmanteau of "costume play". The practice of dressing up as a character from a movie, book, anime, or video game with handmade props.',
      exampleUsage:
          'She won best craft award at Comic-Con for her 7-foot robotic Armored Core cosplay.',
    ),
  ];

  static final List<Map<String, dynamic>> deepDiveTrivia = [
    {
      'question': 'In Dragon Ball Z, who was the first mortal to defeat Son Goku in combat?',
      'options': ['Vegeta', 'Master Roshi (Jackie Chun)', 'Yamcha', 'Tien Shinhan'],
      'answerIndex': 1,
      'explanation':
          'Master Roshi disguised as Jackie Chun defeated young Goku in the final round of the 21st World Martial Arts Tournament.',
    },
    {
      'question': 'What was the exact project code name for the Nintendo GameCube during development?',
      'options': ['Project Reality', 'Project Dolphin', 'Ultra 64', 'Project Atlantis'],
      'answerIndex': 1,
      'explanation':
          'The GameCube was developed under the codename "Dolphin", which is why model numbers start with DOL-001.',
    },
    {
      'question': 'Which Marvel villain created the Infinity Gauntlet in the original 1991 comic series?',
      'options': ['Eternity', 'Thanos himself', 'Eitri the Dwarf', 'Adam Warlock'],
      'answerIndex': 1,
      'explanation':
          'In the comic books, Thanos attached the six gems to his own ordinary left glove to impress Mistress Death.',
    },
    {
      'question': 'What year was the legendary anime Neon Genesis Evangelion first broadcast in Japan?',
      'options': ['1993', '1995', '1998', '2000'],
      'answerIndex': 1,
      'explanation':
          'Evangelion premiered on TV Tokyo on October 4, 1995, directed by Hideaki Anno.',
    },
    {
      'question': 'In League of Legends lore, which ancient empire did Azir rule before its fall?',
      'options': ['Noxus', 'Ionia', 'Shurima', 'Demacia'],
      'answerIndex': 2,
      'explanation':
          'Emperor Azir ruled the golden empire of Shurima before Xerath betrayed him at the Sun Disc.',
    },
  ];

  static final List<Map<String, String>> fanGalleries = [
    {
      'title': 'Cyberpunk Neo-Tokyo Reimagined',
      'artist': 'GhostInTheMatrix',
      'image': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
      'likes': '3.4k',
    },
    {
      'title': 'The Witcher: Kaer Morhen Sunset',
      'artist': 'GeraltArtworks',
      'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      'likes': '5.1k',
    },
    {
      'title': 'Demon Slayer Water Breathing Form X',
      'artist': 'TanjiroBlade',
      'image': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      'likes': '4.8k',
    },
    {
      'title': 'Star Wars: Coruscant Lower Levels',
      'artist': 'JediArchivist',
      'image': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      'likes': '2.9k',
    },
  ];
}
