import 'dart:convert';

class SeedDeepDive {
  SeedDeepDive._();

  static final List<Map<String, dynamic>> defaultTrivia = [
    {
      'trivia_id': 'trivia-1',
      'fandom_category': 'cat_anime',
      'question': 'In Dragon Ball Z, who was the first mortal to defeat Goku in combat?',
      'options_json': jsonEncode(['Vegeta', 'Master Roshi (Jackie Chun)', 'Yamcha', 'Tien']),
      'correct_answer_index': 1,
      'explanation': 'Master Roshi disguised as Jackie Chun defeated young Goku in the 21st World Tournament.',
      'created_at': 1717100000000,
    },
    {
      'trivia_id': 'trivia-2',
      'fandom_category': 'cat_gaming',
      'question': 'What was the Nintendo GameCube\'s development codename?',
      'options_json': jsonEncode(['Project Reality', 'Project Dolphin', 'Ultra 64', 'Project Atlantis']),
      'correct_answer_index': 1,
      'explanation': 'The GameCube was developed as "Dolphin", hence model numbers start with DOL-001.',
      'created_at': 1717100010000,
    },
    {
      'trivia_id': 'trivia-3',
      'fandom_category': 'cat_comics',
      'question': 'Which Marvel villain created the Infinity Gauntlet in the original 1991 comics?',
      'options_json': jsonEncode(['Eternity', 'Thanos himself', 'Eitri the Dwarf', 'Adam Warlock']),
      'correct_answer_index': 1,
      'explanation': 'Thanos attached all 6 Infinity Gems to an ordinary glove — no Eitri was involved in the original.',
      'created_at': 1717100020000,
    },
    {
      'trivia_id': 'trivia-4',
      'fandom_category': 'cat_scifi',
      'question': 'In Star Wars, how did the Millennium Falcon complete the Kessel Run in less than 12 parsecs?',
      'options_json': jsonEncode(['By flying at maximum hyperdrive speed', 'By taking a shorter shortcut near black holes', 'By using secret cloaking shields', 'By jumping through hyperspace wormholes']),
      'correct_answer_index': 1,
      'explanation': 'Parsec is a unit of distance, not time. Han Solo charted a dangerous shortcut near The Maw black hole cluster.',
      'created_at': 1717100030000,
    },
  ];

  static final List<Map<String, dynamic>> defaultAdvancedLore = [
    {
      'lore_id': 'lore-1',
      'fandom_category': 'cat_scifi',
      'title': 'The Creation of Arda: Ainulindalë & The Discord of Melkor',
      'content_body': 'Before the physical universe of Eä existed, Eru Ilúvatar prompted the Ainur to sing a Great Music. Melkor, the most powerful among them, introduced rebellious discordant harmonies, weaving themes of cold, shadow, and fire into the symphony. Eru utilized Melkor\'s vanity to demonstrate that no melody can be sung that has not its uttermost source in Ilúvatar.',
      'difficulty_level': 'Expert',
      'created_at': 1717100000000,
    },
    {
      'lore_id': 'lore-2',
      'fandom_category': 'cat_comics',
      'title': 'The Multiverse Incursions & The Secret Wars Nexus',
      'content_body': 'When universes collapse, the boundary point where two Earths collide is known as an Incursion. The Illuminati discovered that destroyers from the Beyond were collapsing parallel realities. Doctor Doom utilized the Molecule Man as a living nexus bomb to slay the Beyonders, salvaging fragmented realities into the patchwork planet known as Battleworld.',
      'difficulty_level': 'Expert',
      'created_at': 1717100010000,
    },
    {
      'lore_id': 'lore-3',
      'fandom_category': 'cat_gaming',
      'title': 'The Lands Between: Miquella\'s Needle & The Greater Will',
      'content_body': 'In the lore of Elden Ring, Unalloyed Gold is impervious to the influence of Outer Gods like the Frenzied Flame and the Scarlet Rot. Miquella forged needles of unalloyed gold to purge his sister Malenia\'s rot, ultimately shedding his flesh, lineage, and great rune in the Realm of Shadow.',
      'difficulty_level': 'Intermediate',
      'created_at': 1717100020000,
    },
    {
      'lore_id': 'lore-4',
      'fandom_category': 'cat_anime',
      'title': 'The Will of D. & The Ancient Kingdom Void Century',
      'content_body': 'Those who bear the initial "D." in their surname are proclaimed as "the Natural Enemies of God" (the Celestial Dragons). During the 100-year blank period 800 years ago, a technologically advanced sovereign kingdom was wiped out by the twenty founding monarchs, leaving behind unbreakable Poneglyphs.',
      'difficulty_level': 'Intermediate',
      'created_at': 1717100030000,
    },
  ];

  static final List<Map<String, dynamic>> defaultBehindScenes = [
    {
      'scene_id': 'scene-1',
      'fandom_category': 'cat_scifi',
      'title': 'StageCraft LED Volume: The Revolution of Virtual Sets',
      'description': 'Industrial Light & Magic designed circular 20-foot high LED screen volumes powered by Unreal Engine 5 to produce real-time photorealistic in-camera lighting and parallax reflections, replacing traditional green screens.',
      'media_type': 'video',
      'media_url': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      'created_at': 1717100000000,
    },
    {
      'scene_id': 'scene-2',
      'fandom_category': 'cat_comics',
      'title': 'Spider-Verse: Animating on "Twos" and Hand-Drawn Halftones',
      'description': 'To replicate comic book aesthetics, Sony Pictures Imageworks animated characters at 12 frames per second (animating on twos) combined with custom software that dynamically layered Ben-Day dots and hand-drawn line hatching.',
      'media_type': 'article',
      'media_url': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
      'created_at': 1717100010000,
    },
    {
      'scene_id': 'scene-3',
      'fandom_category': 'cat_gaming',
      'title': 'Orchestrating Elden Ring: Recording Budapest Strings',
      'description': 'Composer Yuka Kitamura and Tsukasa Saitoh blended live 80-piece choral chants and brass sections recorded in Budapest to evoke the somber, tragic majesty of the Demigods in the Lands Between.',
      'media_type': 'video',
      'media_url': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
      'created_at': 1717100020000,
    },
    {
      'scene_id': 'scene-4',
      'fandom_category': 'cat_anime',
      'title': 'Studio Ghibli: Hand-Painted Cel Watercolors',
      'description': 'Director Hayao Miyazaki and lead art directors meticulously paint every background in opaque poster color paints on cotton paper, giving every frame an evocative sense of natural wind and breathing foliage.',
      'media_type': 'image',
      'media_url': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
      'created_at': 1717100030000,
    },
  ];

  static final List<Map<String, dynamic>> defaultInterviews = [
    {
      'interview_id': 'interview-1',
      'interviewee_name': 'Hidetaka Miyazaki',
      'role_title': 'President & Game Director, FromSoftware',
      'fandom_category': 'cat_gaming',
      'interview_date': 1716000000000,
      'image_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
      'questions_json': jsonEncode([
        {
          'question': 'How did you approach environmental storytelling in Elden Ring?',
          'answer': 'We want players to feel the weight of history simply by observing broken architecture and the placement of items in the world without requiring exposition dumps.'
        },
        {
          'question': 'What inspired the difficulty curve in the Shadow of the Erdtree expansion?',
          'answer': 'We designed Scadutree Blessings so veteran players could rediscover the sensation of challenge and strategic progression regardless of their initial rune level.'
        }
      ]),
      'created_at': 1717100000000,
    },
    {
      'interview_id': 'interview-2',
      'interviewee_name': 'Denis Villeneuve',
      'role_title': 'Director & Screenwriter, Dune: Part Two',
      'fandom_category': 'cat_scifi',
      'interview_date': 1715500000000,
      'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      'questions_json': jsonEncode([
        {
          'question': 'Why did you choose infrared cameras for the Giedi Prime arena sequences?',
          'answer': 'Under a black sun, sunlight absorbs differently. By shooting with modified Alexa LF infrared sensors, human skin turns translucent and clothes turn into alien monochrome.'
        },
        {
          'question': 'How did Hans Zimmer shape the sandworm soundscape?',
          'answer': 'We wanted the sand to sound alive. Hans utilized Tibetan horn frequencies and rhythmic thumps that resonate directly in the chest cavity.'
        }
      ]),
      'created_at': 1717100010000,
    },
    {
      'interview_id': 'interview-3',
      'interviewee_name': 'Eiichiro Oda',
      'role_title': 'Creator & Manga Artist, One Piece',
      'fandom_category': 'cat_anime',
      'interview_date': 1715000000000,
      'image_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      'questions_json': jsonEncode([
        {
          'question': 'How do you keep the storyline consistent across more than 1,100 chapters?',
          'answer': 'I have kept notebooks since 1997 with the final arc outlined. The characters grew organically, but the ultimate reveal of the One Piece has never changed.'
        },
        {
          'question': 'What does freedom represent for Monkey D. Luffy?',
          'answer': 'Luffy doesn\'t want to conquer anything. He simply wants to be the person with the most freedom on the entire ocean.'
        }
      ]),
      'created_at': 1717100020000,
    },
  ];
}
