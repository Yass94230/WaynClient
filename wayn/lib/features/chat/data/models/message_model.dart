import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wayn/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.chatId,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      senderId: data['senderId'] ?? '', // Ajout d'une valeur par défaut
      content: data['content'] ?? '', // Ajout d'une valeur par défaut
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Gestion du null
      chatId: data['chatId'] ?? '', // Ajout d'une valeur par défaut
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(), // ✅ Utiliser serverTimestamp
      'chatId': chatId,
    };
  }
}
