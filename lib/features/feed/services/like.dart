import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class LikeMethods{
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('nposts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('nposts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }
}