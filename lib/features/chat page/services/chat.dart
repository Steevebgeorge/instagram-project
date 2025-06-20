import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';
import 'package:uuid/uuid.dart';

class ChatFeatures {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
          .orderBy('sent', descending: true)
          .snapshots();
    } catch (e) {
      log('fetching messge code');
      log('Error fetching messages: $e');
      rethrow;
    }
  }

  Future<void> storeMessage(String message, String receiverId) async {
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

  Future<void> updateMessageSeen(String receiverId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('toId', isEqualTo: currentUserId)
        .where('read', isEqualTo: '')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'read': 'seen'});
    }
  }

  Future<String> uploadChatImageToStorage(
      Uint8List file, String receiverId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String id = Uuid().v1();

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    Reference reference =
        _storage.ref().child('Chat_Images').child(chatId).child(id);
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    final imageMessage = MessageModel(
      message: downloadUrl,
      fromId: currentUserId,
      toId: receiverId,
      read: '',
      sent: DateTime.now(),
      type: MessageType.image,
    );

    await _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(imageMessage.toJson());

    return downloadUrl;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserModel user, String receiverId) {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');
    return _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
