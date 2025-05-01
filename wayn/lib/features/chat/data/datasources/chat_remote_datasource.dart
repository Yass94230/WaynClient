import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wayn/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(MessageModel message);
  Future<String> createPrivateChat({
    required String user1Id,
    required String user2Id,
  });
}

class FirebaseChatDataSource implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseChatDataSource(this._firestore);

  @override
  Future<String> createPrivateChat({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      // Débuggons avec des logs
      log('Tentative de création de chat entre $user1Id et $user2Id');

      // Créer un ID unique pour le chat privé
      List<String> sortedIds = [user1Id, user2Id]..sort();
      String chatId = '${sortedIds[0]}_${sortedIds[1]}';

      log('ChatId généré: $chatId');

      // Référence au document
      final chatRef = _firestore
          .collection('rides')
          .doc('test')
          .collection('chat')
          .doc(chatId);

      // Vérifier si le chat existe déjà
      final chatDoc = await chatRef.get();
      log('Chat existe déjà? ${chatDoc.exists}');

      if (!chatDoc.exists) {
        // Créer le chat s'il n'existe pas
        log('Création du nouveau chat...');
        await chatRef.set({
          'type': 'private',
          'memberIds': [user1Id, user2Id],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': null,
          'lastMessageTime': null,
        });

        // Vérifier que le document a bien été créé
        final verificationDoc = await chatRef.get();
        log('Vérification de la création: ${verificationDoc.exists}');
      }

      return chatId;
    } catch (e) {
      log('Erreur lors de la création du chat privé: $e');
      rethrow;
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    try {
      return _firestore
          .collection('rides')
          .doc('test')
          .collection('chat')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        log('Erreur lors de la récupération des messages: $error');
        throw error; // Propager l'erreur plutôt que de retourner une liste vide
      });
    } catch (e) {
      log('Erreur de configuration du stream: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      log('Tentative d\'envoi de message avec chatId: ${message.chatId}');

      final chatRef = _firestore
          .collection('rides')
          .doc('test')
          .collection('chat')
          .doc(message.chatId);

      // Vérifier si le document existe
      final chatDoc = await chatRef.get();
      log('Document exists: ${chatDoc.exists}');

      // Ajouter le message dans la sous-collection 'messages'
      await chatRef.collection('messages').add({
        'chatId': message.chatId,
        'senderId': message.senderId,
        'content': message.content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mettre à jour les métadonnées du chat parent
      await chatRef.update({
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('Message envoyé avec succès');
    } catch (e) {
      log('Erreur lors de l\'envoi du message: $e', error: e);
      rethrow;
    }
  }

  // Méthode utilitaire pour obtenir la référence complète d'un chat
  DocumentReference getChatReference(String chatId) {
    return _firestore
        .collection('rides')
        .doc('test')
        .collection('chat')
        .doc(chatId);
  }
}
