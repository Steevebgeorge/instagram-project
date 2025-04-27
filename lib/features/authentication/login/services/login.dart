import 'package:firebase_auth/firebase_auth.dart';

class Login {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Please fill all fields';
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email format';
        default:
          return 'Login failed: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String> signout() async {
    try {
      await _auth.signOut();
      return 'success';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
