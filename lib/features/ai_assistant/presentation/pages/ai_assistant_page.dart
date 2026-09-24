import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../../domain/entities/chat_message.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  static const _quickPrompts = [
    'Explain the Marvel Multiverse canon',
    'Who would win: Goku or Saitama?',
    'Best anime of this season?',
    'What is Isekai in anime?',
    'How do Comic-Con tickets work?',
    'Tell me about K-Pop fandom culture',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<AIAssistantBloc>().add(SendChatMessageEvent(text.trim()));
    _inputController.clear();
    _scrollToBottom();
  }

  void _showModeSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<AIAssistantBloc>();
    final currentMode = state is AIAssistantLoaded ? (state as AIAssistantLoaded).useOnlineGemini : false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.cpu, size: 20, color: AppColors.darkSecondary),
                SizedBox(width: 8),
                Text('AI Mode Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              onTap: () { bloc.add(const SetAIModeEvent(false)); Navigator.of(ctx).pop(); },
              borderColor: !currentMode ? AppColors.darkSecondary : null,
              child: Row(
                children: [
                  const Icon(Iconsax.flash_1, color: AppColors.darkSecondary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fast Offline FAQs', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Instant answers from curated lore database.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  if (!currentMode) const Icon(Iconsax.tick_circle, color: AppColors.darkSecondary),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              onTap: () { bloc.add(const SetAIModeEvent(true)); Navigator.of(ctx).pop(); },
              borderColor: currentMode ? AppColors.darkPrimary : null,
              child: Row(
                children: [
                  const Icon(Iconsax.cloud, color: AppColors.darkPrimary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Online Gemini AI Studio', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Connected AI — deeper answers (requires internet).', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  if (currentMode) const Icon(Iconsax.tick_circle, color: AppColors.darkPrimary),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  AIAssistantState get state => context.read<AIAssistantBloc>().state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fan Helper', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: _showModeSheet,
          ),
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () => context.read<AIAssistantBloc>().add(const ClearChatHistoryEvent()),
          ),
        ],
      ),
      body: BlocConsumer<AIAssistantBloc, AIAssistantState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          final messages = state is AIAssistantLoaded
              ? state.messages
              : state is AIAssistantTyping
                  ? state.messages
                  : <ChatMessage>[];

          return Column(
            children: [
              // Quick Prompts
              if (messages.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      GlassContainer(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Iconsax.cpu, size: 28, color: AppColors.darkSecondary),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('FandomBot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                    Text('Your AI Lore Companion', style: TextStyle(fontSize: 12, color: AppColors.darkSecondary)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ask me anything about anime lore, gaming history, comic universe timelines, K-Pop culture, or upcoming conventions!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Iconsax.flash_1, size: 16, color: AppColors.darkSecondary),
                          SizedBox(width: 6),
                          Text('Quick Prompts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickPrompts.map((prompt) => GestureDetector(
                          onTap: () => _sendMessage(prompt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.darkPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.darkPrimary.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              prompt,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkPrimary),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (state is AIAssistantTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && state is AIAssistantTyping) {
                        return _TypingIndicator();
                      }
                      return _ChatBubble(message: messages[index]);
                    },
                  ),
                ),
              ],
              if (messages.isNotEmpty) const SizedBox(height: 0) else const Spacer(),

              // Input Field
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: _sendMessage,
                        textInputAction: TextInputAction.send,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Ask about any fandom universe...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _sendMessage(_inputController.text),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.comicRed,
                        ),
                        child: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkSurface,
              ),
              child: const Center(child: Icon(Iconsax.cpu, size: 16, color: AppColors.darkSecondary)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.darkPrimary
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : null,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkSurface,
            ),
            child: const Center(child: Icon(Iconsax.cpu, size: 16, color: AppColors.darkSecondary)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  child: Text('...', style: TextStyle(fontSize: 20, letterSpacing: 4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
