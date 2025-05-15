import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('nposts').doc(postId).delete();
    } catch (e) {
      log(e.toString());
    }
  }
}
