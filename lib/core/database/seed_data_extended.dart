/// Extended seed data for tables not covered in SeedData:
/// posts, glossary, discussions, discussion_replies, star_profiles
class SeedDataExtended {
  SeedDataExtended._();

  // ─────────────────────────────────────────────────────────────────────────
  // POSTS & LORE ARTICLES (8 records)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultPosts = [
    {
      'post_id': 'trend-01',
      'category_id': 'cat_anime',
      'title': 'Solo Leveling: Arise & The Monarch Wars Canon Explained',
      'content_body':
          'From the shadows of the Double Dungeon to the awakening of Sung Jin-woo as the Shadow Monarch, discover how the universe lore bridges the gap between webtoon and animation. The Monarchs system, their origins as vessels of Destruction, and the Counter-Attack system that led to the Great Shadow Sovereign — all examined in detail.',
      'author_name': 'Kenji Sato',
      'image_url': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      'is_trending': 1,
      'is_deep_dive': 0,
      'tags': '["Anime","Monarchs","Lore"]',
      'timestamp': 1727000000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'trend-02',
      'category_id': 'cat_gaming',
      'title': 'Elden Ring Shadow of the Erdtree: Miquella Lore Breakdown',
      'content_body':
          'A deep analytical journey into the Land of Shadow, exploring Saint Trina, Messmer the Impaler, and the ancient divine gate of Enir-Ilim. Miquella\'s sacrifice and his empyrean nature compared to Malenia — the twin demigods dissected.',
      'author_name': 'Elena Rostova',
      'image_url': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800',
      'is_trending': 1,
      'is_deep_dive': 1,
      'tags': '["Elden Ring","FromSoftware","Deep Lore"]',
      'timestamp': 1726900000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'trend-03',
      'category_id': 'cat_scifi',
      'title': 'Dune Messiah: Paul Atreides & The Jihad Consequences',
      'content_body':
          'Exploring Frank Herbert\'s thematic masterstroke: how prescience becomes a prison and why the Golden Path demands supreme sacrifice. Paul\'s jihad claiming 61 billion lives across the universe — an examination of power, prophecy, and tragedy.',
      'author_name': 'David Thorne',
      'image_url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800',
      'is_trending': 1,
      'is_deep_dive': 0,
      'tags': '["Dune","SciFi","Cinema"]',
      'timestamp': 1726800000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'trend-04',
      'category_id': 'cat_comics',
      'title': 'Secret Wars & The Multiverse Collapse: Comic Timeline Primer',
      'content_body':
          'Before the MCU adapts Secret Wars, revisit Jonathan Hickman\'s 2015 saga where Doctor Doom created Battleworld out of dying realities. The Beyonders\' plan, the Molecule Man, and how Reed Richards and Tony Stark played pivotal roles in the Incursions leading to the final collapse.',
      'author_name': 'Marcus Vance',
      'image_url': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'is_trending': 1,
      'is_deep_dive': 1,
      'tags': '["Marvel","Comics","Multiverse"]',
      'timestamp': 1726700000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'news-01',
      'category_id': 'cat_anime',
      'title': 'Chainsaw Man Reze Arc Movie Confirms Worldwide Theatrical Release',
      'content_body':
          'MAPPA studio unveils high-octane explosive teaser trailer featuring Denji and the Bomb Devil in a romantic yet lethal rendezvous across Tokyo. The Reze arc is widely considered the emotional peak of the manga\'s first part — Fujimoto\'s signature gore-meets-tragedy narrative at its finest.',
      'author_name': 'Akira Tanaka',
      'image_url': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=600',
      'is_trending': 0,
      'is_deep_dive': 0,
      'tags': '["Chainsaw Man","MAPPA","Movie"]',
      'timestamp': 1727100000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'news-02',
      'category_id': 'cat_gaming',
      'title': 'Worlds 2025 Grand Finals Announced for London O2 Arena',
      'content_body':
          'Riot Games confirms the premier League of Legends championship will return to Europe, featuring the top 16 regional champions competing for the Summoner\'s Cup. T1 and JDG Gaming are early favorites based on their regional dominance this split.',
      'author_name': 'Sarah Jenkins',
      'image_url': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      'is_trending': 0,
      'is_deep_dive': 0,
      'tags': '["Esports","LoL","Tournament"]',
      'timestamp': 1726950000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'news-03',
      'category_id': 'cat_kpop',
      'title': 'Stray Kids Shatters Stadium Attendance Records Across Asia Leg',
      'content_body':
          'The 8-member self-producing juggernaut wraps up historic stadium dates with bespoke orchestral arrangements of God\'s Menu and MANIAC. STAY (official fandom) reported 94% merch sell-through within the first 30 minutes at every venue stop.',
      'author_name': 'Min-ho Park',
      'image_url': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
      'is_trending': 0,
      'is_deep_dive': 0,
      'tags': '["K-Pop","Stray Kids","Concert"]',
      'timestamp': 1726850000000,
      'is_bookmarked': 0,
    },
    {
      'post_id': 'news-04',
      'category_id': 'cat_movies',
      'title': 'Grand Admiral Thrawn Return Sets Stage for The Mandalorian Climax',
      'content_body':
          'Lucasfilm reveals production blueprints for Dave Filoni\'s upcoming theatrical feature weaving together Ahsoka, Din Djarin, and Imperial remnants under Thrawn. The Grand Admiral\'s tactical genius and connection to the Unknown Regions explored.',
      'author_name': "Liam O'Connor",
      'image_url': 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
      'is_trending': 0,
      'is_deep_dive': 0,
      'tags': '["Star Wars","Mandalorian","Thrawn"]',
      'timestamp': 1726780000000,
      'is_bookmarked': 0,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // GLOSSARY (10 terms)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultGlossary = [
    {
      'term_id': 'gl-01',
      'term': 'Canon',
      'phonetic': '/ˈkæn.ən/',
      'fandom_category': 'Pop Culture & Movies',
      'definition': 'The official, authoritative storyline, events, and character arcs recognized as true within a fictional universe by its original creators.',
      'example_usage': 'The Expanded Universe novels were declared "Legends", making only the films and Clone Wars canon in 2014.',
    },
    {
      'term_id': 'gl-02',
      'term': 'Isekai',
      'phonetic': '/iː.seɪˈkaɪ/',
      'fandom_category': 'Anime & Manga',
      'definition': 'A Japanese genre where a protagonist is transported, summoned, or reincarnated into a parallel or video game world.',
      'example_usage': 'That Time I Got Reincarnated as a Slime is one of the pinnacle modern Isekai light novels.',
    },
    {
      'term_id': 'gl-03',
      'term': 'Speedrun Any%',
      'phonetic': '/ˈspiːd.rʌn ˈɛni pərˈsɛnt/',
      'fandom_category': 'Gaming & Esports',
      'definition': 'A competitive gaming category where the player reaches the final credits as fast as possible using any glitches or sequence breaks allowed.',
      'example_usage': 'The current Any% world record for Breath of the Wild sits under 24 minutes thanks to shield clipping.',
    },
    {
      'term_id': 'gl-04',
      'term': 'Waifu / Husbando',
      'phonetic': '/ˈwaɪ.fuː/',
      'fandom_category': 'Anime & Manga',
      'definition': 'A fictional character from anime, manga, or video games that a fan has affectionate, devoted admiration for as an ideal partner.',
      'example_usage': 'Her room was decorated with tapestries of her favorite waifu, Yor Forger.',
    },
    {
      'term_id': 'gl-05',
      'term': 'Retcon',
      'phonetic': '/ˈrɛt.kɒn/',
      'fandom_category': 'Marvel & DC Comics',
      'definition': 'Short for "Retroactive Continuity". Previously established facts in a fictional universe are altered or ignored by later works.',
      'example_usage': 'The revelation that Bucky Barnes survived and became the Winter Soldier was a masterclass comic retcon.',
    },
    {
      'term_id': 'gl-06',
      'term': 'Stan',
      'phonetic': '/stæn/',
      'fandom_category': 'K-Pop & Idol Culture',
      'definition': 'An intensely enthusiastic, loyal, and supportive fan of a particular idol, music group, or pop icon.',
      'example_usage': 'I have been an active BTS stan since their 2015 HYYH era.',
    },
    {
      'term_id': 'gl-07',
      'term': 'Filler',
      'phonetic': '/ˈfɪl.ər/',
      'fandom_category': 'Anime & Manga',
      'definition': 'Anime episodes or arcs not adapted from the original manga, usually produced so the manga author can write more material ahead.',
      'example_usage': 'Naruto Shippuden features over 40% filler episodes, including the famous Mecha Naruto special.',
    },
    {
      'term_id': 'gl-08',
      'term': 'Cosplay',
      'phonetic': '/ˈkɒz.pleɪ/',
      'fandom_category': 'Pop Culture & Movies',
      'definition': 'A portmanteau of "costume play". Dressing up as a character from a movie, book, anime, or video game with handmade props.',
      'example_usage': 'She won best craft award at Comic-Con for her 7-foot robotic Armored Core cosplay.',
    },
    {
      'term_id': 'gl-09',
      'term': 'Ship / Shipping',
      'phonetic': '/ʃɪp/',
      'fandom_category': 'Anime & Manga',
      'definition': 'The desire for two fictional characters (or real people) to be in a romantic relationship. Derived from "relationship".',
      'example_usage': 'Millions of fans actively ship Naruto and Sasuke despite the canon ending.',
    },
    {
      'term_id': 'gl-10',
      'term': 'Metaverse Lore',
      'phonetic': '/ˈmɛt.ə.vɜːs lɔː/',
      'fandom_category': 'Gaming & Esports',
      'definition': 'The interconnected backstory, world-building, and in-universe history of a fictional game or media universe that spans multiple titles or media.',
      'example_usage': 'The Halo metaverse lore spans 7 mainline games, 14 novels, and multiple animated series.',
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // COMMUNITY DISCUSSIONS (5 threads)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultDiscussions = [
    {
      'thread_id': 'thread-01',
      'user_id': 'fan-01',
      'user_name': 'Alex Mercer',
      'user_badge': 'Master Lorekeeper',
      'category': 'Anime & Manga',
      'title': 'Which Anime Arc Had the Most Impactful Plot Twist of All Time?',
      'body': 'I\'ve been rewatching classic anime and I keep coming back to the Chimera Ant arc in HxH. What do you think is the most impactful plot twist ever? Drop your reasoning — I want to argue about this properly.',
      'upvotes': 847,
      'created_at': 1726500000000,
    },
    {
      'thread_id': 'thread-02',
      'user_id': 'fan-01',
      'user_name': 'Alex Mercer',
      'user_badge': 'Con Veteran 2025',
      'category': 'Gaming & Esports',
      'title': 'Elden Ring Difficulty vs Dark Souls III — Which FromSoft Game is Actually Harder?',
      'body': 'Both games are notorious but I argue Elden Ring is actually easier because of summons, Spirit Ashes, and open-world leveling freedom. DS3 punishes you with no escape. Change my mind.',
      'upvotes': 1204,
      'created_at': 1726400000000,
    },
    {
      'thread_id': 'thread-03',
      'user_id': 'fan-01',
      'user_name': 'Alex Mercer',
      'user_badge': 'Master Lorekeeper',
      'category': 'Marvel & DC Comics',
      'title': 'MCU Phase 6 Secret Wars — Will It Live Up to the Comics?',
      'body': 'The Kang saga bombed. Multiverse of Madness was divisive. Now Secret Wars is the promised payoff. Do you think Marvel Studios can actually pull off the scale of Jonathan Hickman\'s magnum opus? What would you need to see to call it a success?',
      'upvotes': 2341,
      'created_at': 1726300000000,
    },
    {
      'thread_id': 'thread-04',
      'user_id': 'fan-01',
      'user_name': 'Alex Mercer',
      'user_badge': 'Con Veteran 2025',
      'category': 'K-Pop & Idol Culture',
      'title': 'Best K-Pop Albums of 2025 — Ranking Thread',
      'body': 'We are approaching year end and the drops have been incredible. My top 3 so far: 1. STRAY KIDS - ATE 2. AESPA - Whiplash 3. LE SSERAFIM - CRAZY. What are yours and why?',
      'upvotes': 567,
      'created_at': 1726200000000,
    },
    {
      'thread_id': 'thread-05',
      'user_id': 'fan-01',
      'user_name': 'Alex Mercer',
      'user_badge': 'Master Lorekeeper',
      'category': 'Sci-Fi & Fantasy',
      'title': 'Dune vs Foundation — Which Sci-Fi Universe Has Better World-Building?',
      'body': 'Both Asimov\'s Foundation and Herbert\'s Dune represent the pinnacle of speculative fiction. Foundation has psychohistory and the mathematics of civilizations. Dune has ecology, religion, and prescience. Which is the superior constructed universe?',
      'upvotes': 923,
      'created_at': 1726100000000,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // DISCUSSION REPLIES (5 replies across threads)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultReplies = [
    {
      'reply_id': 'reply-01',
      'thread_id': 'thread-01',
      'user_name': 'ShadowMonarchFan',
      'reply_body': 'Nothing hits like Gon\'s transformation moment in HxH. The pure emotional devastation combined with raw power — Togashi created something that transcends anime. The music, the silence, the aftermath. Unmatched.',
      'created_at': 1726510000000,
    },
    {
      'reply_id': 'reply-02',
      'thread_id': 'thread-01',
      'user_name': 'CrunchyrollNerd99',
      'reply_body': 'Attack on Titan — the basement reveal. 4 seasons of buildup for that single moment. Isayama played the entire fandom for years. Goated writing.',
      'created_at': 1726520000000,
    },
    {
      'reply_id': 'reply-03',
      'thread_id': 'thread-02',
      'user_name': 'TarnishedGod',
      'reply_body': 'Disagree completely. Elden Ring Malenia on NG+7 no summons will teach you a new definition of pain. DS3 Nameless King is hard but Malenia heals ON HIT. Skill issue if you think Elden Ring is easier.',
      'created_at': 1726410000000,
    },
    {
      'reply_id': 'reply-04',
      'thread_id': 'thread-03',
      'user_name': 'MarvelChronicler',
      'reply_body': 'For it to work they NEED Hickman himself involved. The Incursions, the Black Priests, the Ivory Kings — that storyline is impossibly complex for 2-3 films. They\'ll simplify and it will disappoint comic readers.',
      'created_at': 1726310000000,
    },
    {
      'reply_id': 'reply-05',
      'thread_id': 'thread-05',
      'user_name': 'SpiceWarrior',
      'reply_body': 'Dune by a galaxy. Foundation is intellectually superior but Dune is FELT. You live in Arrakis. You breathe the dust. Herbert created a complete religion, ecology, language, and political system. Asimov created equations.',
      'created_at': 1726110000000,
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // STAR PROFILES (6 celebrity profiles)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultStarProfiles = [
    {
      'star_id': 'star-01',
      'name': 'Yuki Kaji',
      'fandom_category': 'Anime & Manga',
      'role_title': 'Voice Actor — Eren Yeager (AoT), Todoroki (MHA)',
      'bio': 'One of Japan\'s most prolific voice actors, Yuki Kaji has lent his voice to over 300 anime characters. Known for intense emotional range, he is the definitive voice behind Eren Yeager in Attack on Titan and Shoto Todoroki in My Hero Academia.',
      'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'social_handle': '@yukikaji_official',
      'is_bookmarked': 0,
    },
    {
      'star_id': 'star-02',
      'name': 'Faker (Lee Sang-hyeok)',
      'fandom_category': 'Gaming & Esports',
      'role_title': 'Professional LoL Player — T1 (Mid Lane)',
      'bio': 'Widely regarded as the greatest esports player of all time, Faker has won 4 World Championships with T1 (SKT). His unmatched mechanical skill, game IQ, and longevity in competitive play have made him a cultural icon across Asia and beyond.',
      'image_url': 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
      'social_handle': '@faker',
      'is_bookmarked': 0,
    },
    {
      'star_id': 'star-03',
      'name': 'Bang Chan',
      'fandom_category': 'K-Pop & Idol Culture',
      'role_title': 'Leader & Producer — Stray Kids (3RACHA)',
      'bio': 'Born Chan Bin Christopher Bang in Australia, Bang Chan is the leader, main producer, and creative director of Stray Kids. He produces under the unit 3RACHA and runs a beloved weekly fan interaction livestream called Chan\'s Room.',
      'image_url': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
      'social_handle': '@realbangchan',
      'is_bookmarked': 0,
    },
    {
      'star_id': 'star-04',
      'name': 'Zack Snyder',
      'fandom_category': 'Pop Culture & Movies',
      'role_title': 'Director — DC Extended Universe, Rebel Moon',
      'bio': 'Known for his distinctive visual style and mythological storytelling, Zack Snyder directed Man of Steel, Batman v Superman, and the legendary 4-hour Snyder Cut of Justice League. His passionate fanbase, the SnyderVerse community, is one of the most dedicated in cinema.',
      'image_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      'social_handle': '@zacksnyder',
      'is_bookmarked': 0,
    },
    {
      'star_id': 'star-05',
      'name': 'Eiichiro Oda',
      'fandom_category': 'Anime & Manga',
      'role_title': 'Manga Author — One Piece (1997–Present)',
      'bio': 'The creator of One Piece, the best-selling manga series in history with over 520 million copies in circulation. Oda has built the world of One Piece for over 27 years with unparalleled consistency in foreshadowing and world-building depth.',
      'image_url': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
      'social_handle': '@eiichiro_staff',
      'is_bookmarked': 0,
    },
    {
      'star_id': 'star-06',
      'name': 'Hideo Kojima',
      'fandom_category': 'Gaming & Esports',
      'role_title': 'Game Director & Designer — Death Stranding, Metal Gear',
      'bio': 'Often called the "Spielberg of Gaming", Hideo Kojima is the creative visionary behind the Metal Gear Solid franchise and Death Stranding. His studio Kojima Productions pushes the boundaries between cinema and interactive storytelling.',
      'image_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'social_handle': '@HIDEO_KOJIMA_EN',
      'is_bookmarked': 0,
    },
  ];
}
