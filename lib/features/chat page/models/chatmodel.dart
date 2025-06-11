class MessageModel {
  final String message;
  final String fromId;
  final String toId;
  final String read;
  final sent;
  final MessageType type;

  MessageModel({
    required this.message,
    required this.fromId,
    required this.toId,
    required this.read,
    required this.sent,
    required this.type,
  });
  Map<String, dynamic> toJson() => {
        'fromId': fromId,
        'message': message,
        'toId': toId,
        'read': read,
        'sent': sent,
        'type': type.name,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        message: json['message'] ?? '',
        fromId: json['fromId'] ?? '',
        toId: json['toId'] ?? '',
        read: json['read'] ?? '',
        sent: json['sent'] ?? '',
        type: json['type'] == MessageType.image.name
            ? MessageType.image
            : MessageType.text);
  }
}

enum MessageType { text, image }
