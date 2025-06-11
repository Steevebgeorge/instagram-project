import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';

class ChatFeatures {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String userId, String contactId) {
    List<String> ids = [userId, contactId];
    ids.sort();
    String chatId = ids.join('_');
    try {
      return _firebaseFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sent', descending: false)
          .snapshots();
    } catch (e) {
      log('fetching messge code');
      log('Error fetching messages: $e');
      rethrow;
    }
  }

  Future<void> storeMessage(
      UserModel user, String message, String receiverId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    MessageModel newMessage = MessageModel(
      message: message,
      fromId: currentUserId,
      toId: receiverId,
      read: '',
      sent: DateTime.now(),
      type: MessageType.text,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    await _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toJson());
  }
}
