import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';

class GetUserDetails {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    DocumentSnapshot snap =
        await _storage.collection('users').doc(currentUser.uid).get();

    if (!snap.exists) {
      log('Error in getting user details');
      throw Exception("User does not exist");
    }

    return UserModel.fromJson(snap.data() as Map<String, dynamic>);
  }
}
