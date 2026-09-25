import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  bool _useOnlineGroq = false;

  // Groq API config
  static const String _groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqApiKey =
      'gsk_1E2QPtpqLjsGbanCu3EDWGdyb3FYXwEpFyXEo2b1HdkG1bG74SfWS';
  static const String _groqModel = 'llama3-8b-8192';

  // System prompt — short answers only
  static const String _systemPrompt =
      'You are FandomBot, an AI assistant for the Fandom Verse app. '
      'You know about anime, manga, comics, K-pop, gaming, conventions, and pop culture. '
      'Always reply in 2-3 sentences maximum. Be concise and direct. '
      'Do not write long paragraphs.';

  // Offline FAQ Knowledge Base
  static const Map<String, String> _faqDatabase = {
    'multiverse':
        'Marvel\'s Multiverse has infinite alternate realities — Earth-616 is main comics, Earth-199999 is MCU. Key events: Secret Wars (2015) and upcoming MCU Secret Wars.',
    'manga':
        'Manga is Japanese comics read right-to-left. Major genres: Shonen (action), Seinen (adult), Shoujo (romance), Isekai. Big publishers: Weekly Shonen Jump, Magazine.',
    'speedrun':
        'Speedrunning means completing a game as fast as possible using glitches and optimized routes. Any% = fastest by any means. Tracked at speedrun.com.',
    'goku saitama':
        'Saitama is a gag character with no power ceiling; Goku is bound by in-universe scaling. A definitive answer is narratively impossible.',
    'kpop':
        'K-Pop is South Korean pop music. Top groups: BTS (ARMY), Blackpink (BLINK), Stray Kids, aespa. Major awards: MAMA, Melon Music Awards.',
    'comic con':
        'Comic-Con San Diego is the world\'s biggest pop culture convention, held every July. Other major cons: Anime Expo (LA), MCM London, Tokyo Game Show.',
    'anime':
        'Anime is Japanese animation. Top studios: Ghibli, MAPPA, Ufotable. Stream on Crunchyroll, Netflix, Amazon Prime. Releases follow seasonal calendar.',
    'elden ring':
        'Elden Ring (2022) is a FromSoftware open-world RPG co-written by George R.R. Martin. DLC: Shadow of the Erdtree (2024). Sold 25M+ copies.',
    'pokemon':
        'Pokémon started in 1995, now has 1,025 species. Made by Game Freak, anime by OLM. Annual World Championships, 13,000+ TCG cards.',
    'marvel':
        'Marvel Earth-616 spans 80+ years of comics. MCU started with Iron Man (2008), Phase 6 ends with Secret Wars. Next big projects: Avengers: Doomsday, X-Men.',
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

  Future<void> _onSendMessage(
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

    String aiResponse;

    if (_useOnlineGroq) {
      aiResponse = await _callGroqApi(event.message);
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
      aiResponse = _generateFAQResponse(event.message);
    }

    final aiMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      text: aiResponse,
      sender: ChatSender.ai,
      timestamp: DateTime.now(),
    );

    emit(AIAssistantLoaded(
      messages: [...currentMessages, aiMsg],
      useOnlineGemini: _useOnlineGroq,
    ));
  }

  /// Calls Groq REST API — llama3-8b-8192 model
  Future<String> _callGroqApi(String userMessage) async {
    try {
      final response = await http
          .post(
            Uri.parse(_groqApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqApiKey',
            },
            body: jsonEncode({
              'model': _groqModel,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'max_tokens': 150,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';
        return content.trim().isNotEmpty
            ? content.trim()
            : _generateFAQResponse(userMessage);
      } else {
        debugPrint('[GroqAPI] Error ${response.statusCode}: ${response.body}');
        return '⚠️ Groq API error (${response.statusCode}). Switching to offline mode.';
      }
    } catch (e) {
      debugPrint('[GroqAPI] Exception: $e');
      return '⚠️ Could not reach Groq. Check your internet connection.';
    }
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
    emit(AIAssistantLoaded(messages: [], useOnlineGemini: _useOnlineGroq));
  }

  void _onSetAIMode(
    SetAIModeEvent event,
    Emitter<AIAssistantState> emit,
  ) {
    _useOnlineGroq = event.useOnlineGemini;
    if (state is AIAssistantLoaded) {
      final current = state as AIAssistantLoaded;
      emit(AIAssistantLoaded(
          messages: current.messages, useOnlineGemini: _useOnlineGroq));
    }
  }

  String _generateFAQResponse(String userInput) {
    final input = userInput.toLowerCase();

    for (final entry in _faqDatabase.entries) {
      final keywords = entry.key.split(' ');
      if (keywords.any((kw) => input.contains(kw))) {
        return entry.value;
      }
    }

    final genericResponses = [
      '⚡ Interesting question! This topic has a lot of debate in the fandom community. Check the official wiki for the most accurate answer.',
      '📜 Great question! Different source materials give varying answers. The original canon is usually the safest reference.',
      '🎮 This depends on which version or era you mean. Patch notes and DLC often change established lore.',
      '🌟 The fandom community debates this a lot. Most veterans point to the original source material for the definitive answer.',
      '🎭 Fan theories on this are huge! The official answer might surprise you — worth checking the wiki.',
    ];

    return genericResponses[Random().nextInt(genericResponses.length)];
  }
}
