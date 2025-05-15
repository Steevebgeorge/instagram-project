import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileActions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        _firestore.collection('users').doc(followId).update(
          {
            'followers': FieldValue.arrayRemove([uid])
          },
        );

        _firestore.collection('users').doc(uid).update(
          {
            'following': FieldValue.arrayRemove([followId])
          },
        );
      } else {
        _firestore.collection('users').doc(followId).update(
          {
            'followers': FieldValue.arrayUnion([uid])
          },
        );

        _firestore.collection('users').doc(uid).update(
          {
            'following': FieldValue.arrayUnion([followId])
          },
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
