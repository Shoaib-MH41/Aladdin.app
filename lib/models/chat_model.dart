class ChatMessage {
  final String id;
  final String sender; // "user" or "ai"
  final String text;
  final DateTime timestamp;
  final bool isCode;
  final bool isDesign; // نیا فیلڈ
  final Map<String, dynamic>? designData; // نیا فیلڈ

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isCode = false,
  // ... existing parameters ...
    this.isDesign = false,
    this.designData,
  });


  // Map میں بدلنا (API/Database کے لیے)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Map سے واپس object بنانا
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sender: map['sender'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
