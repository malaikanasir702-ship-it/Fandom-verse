import '../domain/entities/discussion_thread.dart';
import '../domain/entities/star_profile.dart';

class CommunityMockData {
  CommunityMockData._();

  static final List<DiscussionThread> threads = [
    DiscussionThread(
      id: 'th-01',
      userId: 'user-02',
      userName: 'TargaryenLore',
      userBadge: 'Lorekeeper',
      category: 'Sci-Fi & Fantasy',
      title: 'House of the Dragon: The Real Meaning of Aegon\'s Prophecy',
      body:
          'Was Aegon the Conqueror driven by pure ambition, or did his vision of the Prince That Was Promised truly justify burning Harrenhal? Let\'s discuss the Targaryen ancestral curse.',
      upvotes: 142,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      replies: [
        DiscussionReply(
          id: 'rep-01',
          userName: 'ValyrianSteel',
          userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          body: 'Viserys believed it with all his heart. The dagger inscription confirms the line of succession.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DiscussionReply(
          id: 'rep-02',
          userName: 'NightKingFan',
          userAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100',
          body: 'Ironically the prophecy was fulfilled through both ice and fire in Jon Snow and Daenerys.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ],
    ),
    DiscussionThread(
      id: 'th-02',
      userId: 'user-03',
      userName: 'ShadowMonarch_99',
      userBadge: 'Speedrunner',
      category: 'Anime & Manga',
      title: 'Solo Leveling Ragnarok: Suho\'s Powers vs Jin-woo',
      body:
          'In the spin-off, how do the primordial monarchs balance the power levels compared to the original manhwa climax? Is the shadow army too overpowered?',
      upvotes: 98,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      replies: [
        DiscussionReply(
          id: 'rep-03',
          userName: 'HwangDongSoo',
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
          body: 'The Itarim gods from outer space provide a necessary cosmic threat to challenge the shadow army.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
    DiscussionThread(
      id: 'th-03',
      userId: 'user-04',
      userName: 'CosplayValkyrie',
      userBadge: 'Con Veteran',
      category: 'Gaming & Esports',
      title: 'First-timer tips for attending Comic-Con in full armor cosplay',
      body:
          'Sharing my 5 essential rules: 1) Hydration pack inside breastplate, 2) EVA foam sealant, 3) Emergency hot glue gun in your kit, 4) Proper convention floor footwear!',
      upvotes: 215,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      replies: [
        DiscussionReply(
          id: 'rep-04',
          userName: 'MechaBuilder',
          userAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100',
          body: 'Rule #1 is a lifesaver. Convention halls get sweltering after 2 hours.',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ],
    ),
  ];

  static final List<StarProfile> starProfiles = [
    StarProfile(
      id: 'star-01',
      name: 'Kenjiro Tsuda',
      category: 'Anime & Manga',
      roleTitle: 'Legendary Voice Actor (Seiyuu)',
      bio:
          'Renowned Japanese actor and seiyuu famous for his iconic baritone voice behind Kento Nanami (Jujutsu Kaisen), Seto Kaiba (Yu-Gi-Oh!), and Kishibe (Chainsaw Man).',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
      socialHandle: '@tsuda_ken',
      famousWorks: ['Jujutsu Kaisen', 'Chainsaw Man', 'Yu-Gi-Oh!', 'Golden Kamuy'],
    ),
    StarProfile(
      id: 'star-02',
      name: 'Hidetaka Miyazaki',
      category: 'Gaming & Esports',
      roleTitle: 'Game Director & President of FromSoftware',
      bio:
          'Visionary game designer who created the Soulslike genre. Director of Demon\'s Souls, Dark Souls, Bloodborne, Sekiro: Shadows Die Twice, and Elden Ring.',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      socialHandle: '@fromsoftware_pr',
      famousWorks: ['Dark Souls Trilogy', 'Bloodborne', 'Sekiro', 'Elden Ring'],
    ),
    StarProfile(
      id: 'star-03',
      name: 'Jeon Jungkook',
      category: 'K-Pop & Idol Culture',
      roleTitle: 'Vocalist, Performer & Global Pop Icon',
      bio:
          'Golden Maknae of BTS and multi-platinum solo artist behind the record-breaking global hit "Seven" and debut album "Golden". Known for versatile vocals and stage charisma.',
      imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
      socialHandle: '@bowwow_bam',
      famousWorks: ['Seven (feat. Latto)', 'Standing Next to You', 'Euphoria', 'Dreamers'],
    ),
    StarProfile(
      id: 'star-04',
      name: 'Jim Lee',
      category: 'Marvel & DC Comics',
      roleTitle: 'Comic Book Legend, Artist & DC President',
      bio:
          'One of the most revered and influential comic book artists in history. Co-founder of Image Comics and legendary illustrator of X-Men #1 and Batman: Hush.',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      socialHandle: '@jimlee',
      famousWorks: ['X-Men #1 (1991)', 'Batman: Hush', 'Superman: For Tomorrow'],
    ),
  ];
}
