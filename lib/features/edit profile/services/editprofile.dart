import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEdit {
  final _firebase = FirebaseFirestore.instance;

  Future<void> updateProfile(
      String userName, String bio, String userId, String photoUrl) async {
    _firebase.collection('users').doc(userId).update({
      'userName': userName,
      'bio': bio,
      'photoUrl': photoUrl,
    });
  }
}
