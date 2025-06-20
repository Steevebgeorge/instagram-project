import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';

class AppActivities {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(UserModel user) {
    return _firebaseFirestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    await _firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .update({'isOnline': isOnline, 'lastActive': DateTime.now()});
  }
}
