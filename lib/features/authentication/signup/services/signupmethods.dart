import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/authentication/signup/services/storagemethod.dart';

class Signup {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUp({
    required String email,
    required String password,
    required String userName,
    required Uint8List file,
  }) async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          userName.isEmpty ||
          file.isEmpty) {
        return "All fields are required";
      }
      if (password.length < 6) {
        return "Password must be at least 6 characters long";
      }
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String photoUrl =
          await ProfileImageStorageMethod().uploadImageToStorage(file);

      UserModel user = UserModel(
          email: email,
          uid: credential.user!.uid,
          photoUrl: photoUrl,
          userName: userName,
          bio: '',
          followers: [],
          following: []);

      await _firestore.collection("users").doc(credential.user!.uid).set(
            user.toJson(),
          );
      return 'success creating account';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Authentication error: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
}
