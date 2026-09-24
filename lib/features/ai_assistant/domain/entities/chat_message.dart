enum ChatSender { user, ai, system }

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final bool isThinking;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isThinking = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatSender? sender,
    DateTime? timestamp,
    bool? isThinking,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
