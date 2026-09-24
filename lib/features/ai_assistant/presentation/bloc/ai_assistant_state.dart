import '../../domain/entities/chat_message.dart';

abstract class AIAssistantState {
  const AIAssistantState();
}

class AIAssistantInitial extends AIAssistantState {
  final bool useOnlineGemini;
  const AIAssistantInitial({this.useOnlineGemini = false});
}

class AIAssistantTyping extends AIAssistantState {
  final List<ChatMessage> messages;
  const AIAssistantTyping(this.messages);
}

class AIAssistantLoaded extends AIAssistantState {
  final List<ChatMessage> messages;
  final bool useOnlineGemini;
  const AIAssistantLoaded({required this.messages, this.useOnlineGemini = false});
}

class AIAssistantError extends AIAssistantState {
  final String message;
  final List<ChatMessage> previousMessages;
  const AIAssistantError(this.message, this.previousMessages);
}
