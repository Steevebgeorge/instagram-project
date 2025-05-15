import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/add%20post/models/postmodel.dart';
import 'package:instagram/features/add%20post/services/storagemethods.dart';
import 'package:uuid/uuid.dart';

class PostStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //upload Post
  Future<String> uploadPost(
    Uint8List file,
    String caption,
    String uid,
    String userName,
    String profileImage,
    String postLocation,
  ) async {
    String res = "some error occured";
    try {
      String photoUrl = await PostStorageMethod().uploadImageToStorage(file);
      String postId = const Uuid().v1();
      PostModel post = PostModel(
        description: caption,
        uid: uid,
        userName: userName,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
        location: postLocation,
      );
      _firestore.collection('nposts').doc(postId).set(post.toJson());
      res = "success";
      log("post uploaded successfully");
    } catch (e) {
      res = e.toString();
      log('error uploading post');
    }
    return res;
  }
}
