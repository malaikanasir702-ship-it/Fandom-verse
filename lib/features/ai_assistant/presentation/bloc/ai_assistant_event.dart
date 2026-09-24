abstract class AIAssistantEvent {
  const AIAssistantEvent();
}

class SendChatMessageEvent extends AIAssistantEvent {
  final String message;
  const SendChatMessageEvent(this.message);
}

class SelectQuickPromptEvent extends AIAssistantEvent {
  final String prompt;
  const SelectQuickPromptEvent(this.prompt);
}

class ClearChatHistoryEvent extends AIAssistantEvent {
  const ClearChatHistoryEvent();
}

class SetAIModeEvent extends AIAssistantEvent {
  final bool useOnlineGemini;
  const SetAIModeEvent(this.useOnlineGemini);
}
