import 'dart:convert';

class SeedHeroStories {
  SeedHeroStories._();

  static final List<Map<String, dynamic>> defaultStories = [
    {
      'story_id': 'story-spiderman',
      'hero_name': 'Spider-Man',
      'category': 'Marvel Comics',
      'avatar_url': 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400',
      'ring_color_hex': '#E51924',
      'tagline': 'With great power comes great responsibility.',
      'origin_backstory':
          'Peter Benjamin Parker was an orphaned, academically brilliant Midtown High student living in Forest Hills, Queens with his loving Uncle Ben and Aunt May. During an exhibition on radioactivity, an ordinary common house spider was irradiated by a particle accelerator particle beam and bit Peter before dying.\n\nPeter soon discovered he had acquired the proportionate strength, speed, wall-crawling agility, and precognitive "spider-sense" of an arachnid. Initially seeking personal fame, Peter crafted a costume and web-shooters to become a televised wrestling sensation. After a match, he carelessly allowed a fleeing burglar to escape, cynically remarking that catching thieves was not his job.\n\nDays later, Peter returned home to the horrifying news that Uncle Ben had been shot and killed by an armed burglar. Tracking down the murderer at an abandoned warehouse, Peter made the devastating discovery that the killer was the very burglar he had let go. Overcome with remorse and realizing that inaction has consequences, Peter committed his entire existence to Uncle Ben\'s timeless principle: "With great power comes great responsibility."',
      'life_history':
          'Peter Parker\'s career as Spider-Man is defined by immense personal sacrifice and unwavering moral grit. Balancing his undergraduate studies at Empire State University with freelance photojournalism for J. Jonah Jameson\'s Daily Bugle, Peter protected New York City against an infamous rogues gallery including Green Goblin (Norman Osborn), Doctor Octopus, Electro, Kraven the Hunter, and Mysterio.\n\nHis greatest tragedy occurred atop the George Washington Bridge, where the Green Goblin hurled Gwen Stacy to her death—a catastrophic event that fundamentally reshaped comic book history. Later, during the intergalactic Secret Wars, Peter acquired an alien symbiote costume that enhanced his powers; upon discovering it was sentient and attempting to bond permanently, he rejected it, inadvertently creating his most terrifying adversary, Venom.\n\nThrough the years, Peter married Mary Jane Watson, joined the Avengers and Future Foundation, survived the devastating Clone Saga and "Superior Spider-Man" era, and mentored young Miles Morales across the multiverse. Despite bearing poverty, loss, and public misunderstanding, Spider-Man remains the heart and conscience of the Marvel Universe.',
      'powers_abilities':
          '• Superhuman Strength (lifts up to 20-25 tons)\n• Superhuman Agility, Speed, Equilibrium & Reflexes (15x human maximum)\n• Precognitive Spider-Sense danger alarm\n• Wall-Crawling & Bio-Magnetic surface adhesion\n• Genius-Level Intellect in biochemistry, physics & electronics\n• Twin Wrist-Mounted Mechanical Web-Shooters firing high-tensile web-fluid',
      'first_appearance': 'Amazing Fantasy #15 (August 1962)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
          'caption': '🕷️ "With great power comes great responsibility."',
          'tag': '#SpiderMan',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1601645191163-3fc0d5d64e35?w=800',
          'caption': 'Peter Parker swings into action across Manhattan! 🌆',
          'tag': '#Marvel',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1608889175123-8ee362201f81?w=800',
          'caption': 'The Multiverse saga continues… are you ready? 🌌',
          'tag': '#NoWayHome',
        },
      ]),
      'created_at': 1710000001000,
    },
    {
      'story_id': 'story-batman',
      'hero_name': 'Batman',
      'category': 'DC Comics',
      'avatar_url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400',
      'ring_color_hex': '#1E88E5',
      'tagline': 'I am vengeance. I am the night. I am Batman.',
      'origin_backstory':
          'Born into Gotham City\'s wealthiest aristocratic dynasty, eight-year-old Bruce Wayne had his idyllic childhood shattered when his parents, Dr. Thomas Wayne and Martha Wayne, were gunned down before his eyes by mugger Joe Chill in Crime Alley.\n\nKneeling in a pool of his parents\' blood, Bruce made a sacred vow to rid Gotham of the evil that stole his family. Raised by the devoted Wayne butler Alfred Pennyworth, Bruce spent over a decade traveling the globe to master 127 martial arts disciplines, criminal psychology, forensic pathology, and stealth infiltration. Upon returning to Gotham, he realized physical prowess was insufficient—criminals needed to fear consequences. When a bat crashed through his study window at Wayne Manor, Bruce seized it as an omen: "Criminals are a superstitious, cowardly lot. I shall become a bat."',
      'life_history':
          'Operating from the high-tech subterranean Batcave, Bruce Wayne financed his crusade using Wayne Enterprises\' vast industrial resources. Clad in ballistic-weave armor and brandishing non-lethal WayneTech weaponry, Batman revolutionized crimefighting while locked in perpetual psychological warfare against psychotic adversaries such as the Joker, the Riddler, Two-Face, Scarecrow, Ra\'s al Ghul, and the monstrous brute Bane (who famously fractured his spine in Knightfall).\n\nRecognizing the burden was too heavy to carry alone, Batman trained Dick Grayson as Robin (who later evolved into Nightwing), followed by Barbara Gordon, Jason Todd, Tim Drake, and his own biological son Damian Wayne. As the premier tactician and financier of the Justice League alongside Superman and Wonder Woman, Batman routinely outmaneuvers cosmic gods and intergalactic invaders through pure intellect, preparation, and indomitable will.',
      'powers_abilities':
          '• Peak Human Physical Conditioning & Olympic-Class Athletics\n• Master of 127 Martial Arts Styles & Lethal Combat Forms\n• World\'s Greatest Detective & Master Forensics Scientist\n• Genius-Level Intellect, Master Strategist & Polymath\n• Master of Infiltration, Escapology & Intimidation Tactics\n• Multi-billion dollar WayneTech arsenal: Batmobile, Batwing, Kevlar suit & Utility Belt',
      'first_appearance': 'Detective Comics #27 (May 1939)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800',
          'caption': '🦇 "I am vengeance. I am the night."',
          'tag': '#Batman',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1613376023733-0a73315d9b06?w=800',
          'caption': 'Gotham City never sleeps — neither does the Dark Knight. 🌃',
          'tag': '#DCComics',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
          'caption': 'Billionaire by day. Vigilante by night. 🖤',
          'tag': '#BruceWayne',
        },
      ]),
      'created_at': 1710000002000,
    },
    {
      'story_id': 'story-wolverine',
      'hero_name': 'Wolverine',
      'category': 'X-Men',
      'avatar_url': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400',
      'ring_color_hex': '#FFCC00',
      'tagline': 'I\'m the best there is at what I do, but what I do isn\'t very nice.',
      'origin_backstory':
          'Born in late 19th-century Alberta, Canada as James Howlett, his dormant mutant genetic mutation violently manifested during a family tragedy, causing razor-sharp bone claws to erupt from the backs of his hands. Fleeing into the frozen wilderness, he adopted the name "Logan" and spent decades surviving among wolves and fighting in nearly every major global military conflict, including World War I and World War II alongside Captain America.\n\nLogan\'s mutant physiology grants him an extraordinary cellular healing factor that neutralizes deadly toxins, regrows shattered organs and limbs, and slows his aging process to a crawl, accompanied by predatory animal senses and enhanced strength.',
      'life_history':
          'During the Cold War, Logan was captured by the shadowy military research group Weapon X, led by Dr. Abraham Cornelius. Under unspeakable agony, scientists molecularly bonded an indestructible alien alloy—Adamantium—to his entire skeletal framework and bone claws. The trauma shattered his memories, turning him into a wild berserker who slaughtered the laboratory staff to escape.\n\nEventually recruited by Professor Charles Xavier to join the X-Men, Logan found redemption, family, and honor. He became a samurai in Japan, forged unbreakable bonds with Cyclops, Storm, and Jean Grey, led X-Force on black-ops missions, and fought beside the Avengers, cementing his stature as mutantkind\'s most ferocious defender.',
      'powers_abilities':
          '• Regenerative Healing Factor (recovers from incinerations, dismemberment & toxins)\n• Indestructible Adamantium Skeleton & 6 Retractable Adamantium Claws\n• Superhuman Animalistic Senses (tracks prey across continents by scent alone)\n• Berserker Rage mode granting exponential physical ferocity\n• Decades of Master Samurai Martial Arts & Global Black-Ops Military Training',
      'first_appearance': 'The Incredible Hulk #180 (October 1974)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800',
          'caption': '⚡ "I\'m the best there is at what I do."',
          'tag': '#Wolverine',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800',
          'caption': 'Adamantium claws. Healing factor. Unlimited rage. 🔥',
          'tag': '#XMen',
        },
      ]),
      'created_at': 1710000003000,
    },
    {
      'story_id': 'story-wonderwoman',
      'hero_name': 'Wonder Woman',
      'category': 'DC Comics',
      'avatar_url': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
      'ring_color_hex': '#E51924',
      'tagline': 'Only love can truly save the world.',
      'origin_backstory':
          'Hidden by divine mists in the Bermuda Triangle lies Themyscira, island sanctuary of the immortal Amazon warriors. Yearning for a daughter, Queen Hippolyta sculpted an infant form out of pristine clay, and the Olympian Pantheon blessed the child with life and divine gifts: the superhuman might of Demeter, wisdom of Athena, peerless speed of Hermes, and the hunting precision of Artemis.\n\nNamed Diana, she blossomed into the greatest combatant on paradise island. When US Air Force pilot Steve Trevor\'s aircraft crashed offshore, Diana bested all Amazonian sisters in an ancient contest of champions, earning the right to travel to Patriarch\'s World as Themyscira\'s champion ambassador.',
      'life_history':
          'Arriving in "Man\'s World" during the throes of devastating global war, Diana championed compassion, equality, and truth as Wonder Woman. Armed with the divine golden Lasso of Truth forged by Hephaestus and indestructible Aegis Bracelets of Submission, she conquered the God of War Ares, Cheetah, and sorceress Circe.\n\nAlongside Superman and Batman, Diana forms DC\'s Trinity—the beating heart of the Justice League. Uniting divine warrior ferocity with unmatched diplomatic empathy, Wonder Woman stands as the world\'s greatest female superhero icon.',
      'powers_abilities':
          '• Divine Superhuman Strength, Durability & Longevity\n• Supersonic Flight & Hermes-blessed Speed\n• Master of Ancient Greek & Amazonian Weapons Combat\n• Golden Lasso of Truth (unbreakable, compels absolute truth)\n• Bullet-deflecting Bracelets of Submission & Aegis Shield',
      'first_appearance': 'All Star Comics #8 (October 1941)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
          'caption': '⚡ Diana, Princess of the Amazons.',
          'tag': '#WonderWoman',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
          'caption': 'Born from clay, forged for war, fighting for love. 🏛️',
          'tag': '#DCComics',
        },
      ]),
      'created_at': 1710000004000,
    },
    {
      'story_id': 'story-deadpool',
      'hero_name': 'Deadpool',
      'category': 'Marvel Comics',
      'avatar_url': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400',
      'ring_color_hex': '#8E24AA',
      'tagline': 'Maximum effort!',
      'origin_backstory':
          'Wade Winston Wilson was a dishonorably discharged Canadian Special Forces mercenary who accepted assassination contracts only on individuals he believed deserved elimination. After falling deeply in love with Vanessa Carlysle, Wade was diagnosed with terminal, inoperable cancer spanning 34 vital organs.\n\nDesperate for a cure, Wade volunteered for Department K, a black-ops program aiming to replicate Wolverine\'s healing factor. The experimental serum halted the cancer by accelerating cellular regeneration, but caused his cancer cells to replicate at the exact same furious rate, leaving his body severely scarred. Branded a failure, Wade was cast into the "Hospice", where sadistic administrator Ajax tortured inmates in the "Deadpool" mortality pool. Surviving an execution attempt, Wade broke free, crafted his iconic red-and-black suit, and christened himself Deadpool.',
      'life_history':
          'Known universally as the "Merc with a Mouth", Deadpool became the most chaotic operative in existence. Uniquely, Wade possesses "medium awareness"—he knows he exists inside comic books and video games, routinely breaking the Fourth Wall to mock readers, artists, and screenwriters.\n\nThough ostensibly a ruthless mercenary who loves chimichangas, katanas, and explosions, Wade possesses a buried golden heart. He formed celebrated chaotic partnerships with Cable, Spider-Man, and Wolverine, served on the Uncanny X-Force, and continuously strives to prove he can be a legitimate superhero.',
      'powers_abilities':
          '• Supreme Regenerative Healing Factor (survives decapitation & atomization)\n• Total Immunity to Telepathic mind control, diseases & poisons\n• Master Martial Artist, Swordsman & Dual Katana specialist\n• Expert Sniper & Explosives Engineer\n• Fourth-Wall Omniscience & Unpredictable Combat Tactics',
      'first_appearance': 'The New Mutants #98 (February 1991)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
          'caption': '🎭 Breaking the 4th wall since 1991.',
          'tag': '#Deadpool',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
          'caption': 'Maximum effort! 💥',
          'tag': '#MercWithAMouth',
        },
      ]),
      'created_at': 1710000005000,
    },
    {
      'story_id': 'story-ironman',
      'hero_name': 'Iron Man',
      'category': 'Marvel Comics',
      'avatar_url': 'https://images.unsplash.com/photo-1635863138275-d9b33299680b?w=400',
      'ring_color_hex': '#D97706',
      'tagline': 'I am Iron Man.',
      'origin_backstory':
          'Anthony Edward "Tony" Stark was a genius prodigy who graduated from MIT at 17 and inherited Stark Industries, the world\'s leading military defense contractor, after his parents Howard and Maria Stark died in a tragic accident. Arrogant, charismatic, and wealthy, Tony lived carefree until he was ambushed by warlord insurgents while inspecting field weapons in Afghanistan.\n\nA bomb explosion embedded lethal metallic shrapnel near Tony\'s heart. Captured and ordered by terrorists to build the Jericho super-missile, Tony collaborated with fellow captive Dr. Ho Yinsen. Together, they engineered a compact electromagnetic Arc Reactor to prevent the shrapnel from piercing Tony\'s heart, using it to power a crude armor suit (Mark I). Yinsen sacrificed himself during the escape, urging Tony not to waste his life.',
      'life_history':
          'Returning home transformed, Tony made the shock decision to immediately shut down all weapons manufacturing at Stark Industries. Refining his initial crude suit into the sleek gold-and-titanium Mark III armor equipped with flight thrusters, repulsors, and AI assistant J.A.R.V.I.S., Tony announced: "I am Iron Man."\n\nTony co-founded and funded the Avengers, designed specialized armors including the Hulkbuster and Bleeding Edge Nanotech, and took leadership of S.H.I.E.L.D. Through battles against Thanos, Ultron, and the Mandarin, Iron Man proved that the greatest weapon on Earth is a heroic human mind.',
      'powers_abilities':
          '• Super-Genius Polymath Intellect & Master Inventor\n• Nanotech Powered Armor Suit with Mach 8 Supersonic Flight\n• Repulsor Particle Beams & High-Energy Chest Unibeam\n• Autonomous AI Tactical Combat Assistance (J.A.R.V.I.S. / F.R.I.D.A.Y.)\n• Self-Sustaining Miniature Clean-Energy Arc Reactor',
      'first_appearance': 'Tales of Suspense #39 (March 1963)',
      'slides_json': jsonEncode([
        {
          'imageUrl': 'https://images.unsplash.com/photo-1635863138275-d9b33299680b?w=800',
          'caption': '⚡ "I am Iron Man."',
          'tag': '#IronMan',
        },
        {
          'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
          'caption': 'Genius, billionaire, playboy, philanthropist. 🦾',
          'tag': '#Avengers',
        },
      ]),
      'created_at': 1710000006000,
    },
  ];
}
