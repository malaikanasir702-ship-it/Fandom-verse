import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  bool _useOnlineGemini = false;

  // Predefined FAQ Knowledge Base (Offline NLP fallback)
  static const Map<String, String> _faqDatabase = {
    'multiverse': 'The Multiverse in Marvel comics is an infinite collection of alternate realities called "Earth-XXXXXX". The main Marvel Comics universe is Earth-616, while the MCU is Earth-199999. Key multiversal events include Secret Wars (2015) and the upcoming Secret Wars MCU adaptation.',
    'manga': 'Manga is Japanese-style comic art read right-to-left. Key magazines include Weekly Shonen Jump (host to One Piece, Naruto, Dragon Ball) and Weekly Shonen Magazine. Popular genres: Shonen (action/youth), Seinen (adult), Shoujo (romance), and Isekai (transported to another world).',
    'speedrun': 'Speedrunning is completing a video game as fast as possible using glitches, tricks, and optimized routing. Any% = fastest completion by any means. 100% = full completion. Categories are tracked at speedrun.com. Major events: Awesome Games Done Quick (AGDQ), raising millions for charity.',
    'goku saitama': 'This is the ultimate anime debate! Canonically, Saitama has no measurable upper limit to his strength (he is a gag character). Goku is bound by in-universe power scaling. Most analysts suggest Saitama\'s "serious punch" is narratively infinite, making a definitive answer impossible.',
    'kpop': 'K-Pop (Korean Pop) is a global music phenomenon originating in South Korea. Major groups: BTS, Blackpink, Stray Kids, NewJeans, aespa, EXO. Fan communities are called fandoms with official names: BTS = ARMY, Blackpink = BLINK. Major events: MAMA Awards, Melon Music Awards.',
    'comic con': 'Comic-Con International in San Diego is the world\'s largest pop culture convention held every July at the San Diego Convention Center. Tickets sell out in minutes via lottery. Other major cons: Anime Expo (LA), MCM London, Tokyo Game Show, Gamescom (Cologne).',
    'anime': 'Anime is Japanese animation with a distinct visual style. Major studios: Studio Ghibli, MAPPA, Ufotable, Wit Studio. Streaming platforms: Crunchyroll, Funimation, Netflix, Amazon Prime Video. Seasonal releases follow Japan\'s anime calendar (Winter, Spring, Summer, Fall).',
    'elden ring': 'Elden Ring is a 2022 open-world action RPG by FromSoftware and George R.R. Martin. Set in the Lands Between, it follows a Tarnished seeking to restore the Elden Ring. DLC: Shadow of the Erdtree (2024). The game sold 25+ million copies worldwide.',
    'pokemon': 'Pokémon is a media franchise created by Satoshi Tajiri in 1995. Main games by Game Freak, anime by OLM. As of 2024, there are 1,025 Pokémon species. The Pokémon World Championships is held annually. The Trading Card Game has over 13,000 unique cards.',
    'marvel': 'The Marvel Universe (Earth-616) spans 80+ years of comics. Key events: Infinity Gauntlet, Secret Wars, House of X/Powers of X. The MCU (Earth-199999) began with Iron Man (2008). Phase 6 culminates with Secret Wars (film). Key upcoming projects: Avengers: Doomsday, X-Men \'97.',
  };

  AIAssistantBloc() : super(const AIAssistantInitial()) {
    on<SendChatMessageEvent>(_onSendMessage);
    on<SelectQuickPromptEvent>(_onSelectQuickPrompt);
    on<ClearChatHistoryEvent>(_onClearHistory);
    on<SetAIModeEvent>(_onSetAIMode);
  }

  List<ChatMessage> _getCurrentMessages() {
    if (state is AIAssistantLoaded) return (state as AIAssistantLoaded).messages;
    if (state is AIAssistantTyping) return (state as AIAssistantTyping).messages;
    return [];
  }

  void _onSendMessage(
    SendChatMessageEvent event,
    Emitter<AIAssistantState> emit,
  ) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.message,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    final currentMessages = [..._getCurrentMessages(), userMsg];
    emit(AIAssistantTyping(currentMessages));

    await Future.delayed(const Duration(milliseconds: 900));

    final aiResponse = _generateFAQResponse(event.message);
    final aiMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      text: aiResponse,
      sender: ChatSender.ai,
      timestamp: DateTime.now(),
    );

    emit(AIAssistantLoaded(
      messages: [...currentMessages, aiMsg],
      useOnlineGemini: _useOnlineGemini,
    ));
  }

  void _onSelectQuickPrompt(
    SelectQuickPromptEvent event,
    Emitter<AIAssistantState> emit,
  ) {
    add(SendChatMessageEvent(event.prompt));
  }

  void _onClearHistory(
    ClearChatHistoryEvent event,
    Emitter<AIAssistantState> emit,
  ) {
    emit(AIAssistantLoaded(messages: [], useOnlineGemini: _useOnlineGemini));
  }

  void _onSetAIMode(
    SetAIModeEvent event,
    Emitter<AIAssistantState> emit,
  ) {
    _useOnlineGemini = event.useOnlineGemini;
    if (state is AIAssistantLoaded) {
      final current = state as AIAssistantLoaded;
      emit(AIAssistantLoaded(messages: current.messages, useOnlineGemini: _useOnlineGemini));
    }
  }

  String _generateFAQResponse(String userInput) {
    final input = userInput.toLowerCase();

    // Search FAQ database for keyword matches
    for (final entry in _faqDatabase.entries) {
      final keywords = entry.key.split(' ');
      if (keywords.any((kw) => input.contains(kw))) {
        return entry.value;
      }
    }

    // Generic intelligent-sounding fallback responses
    final genericResponses = [
      '⚡ Great question! Based on my Fandom Universe database, this topic spans multiple continuities. The most widely accepted canonical answer involves complex lore developed over several decades of storytelling.',
      '📜 From the Lorekeeper archives: This is a hotly debated topic in the fandom community. Different source materials (comics, anime, games) provide varying interpretations. I recommend checking the official wikis for the most up-to-date consensus.',
      '🌟 Excellent deep dive query! The community has debated this across forums like Reddit r/anime and r/comicbooks. Most veteran fans agree that the original source material provides the most accurate canon reference.',
      '🎮 From my Gaming & Esports data: This question depends heavily on which era or version you\'re referencing. Patch updates and DLC releases often alter the established lore significantly.',
      '🎭 Fan theories about this topic are incredibly popular! While the official answer may be one thing, the creative fandom community has built fascinating alternate universe interpretations worth exploring.',
    ];

    return genericResponses[Random().nextInt(genericResponses.length)];
  }
}
