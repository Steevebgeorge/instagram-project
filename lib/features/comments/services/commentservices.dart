import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CommentServices {
  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profileImage,
  ) async {
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        await FirebaseFirestore.instance
            .collection('nposts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
          {
            'profilePic': profileImage,
            'name': name,
            'text': text,
            'uid': uid,
            'date': DateTime.now(),
            'commentId': commentId,
          },
        );
        log('Comment added');
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
