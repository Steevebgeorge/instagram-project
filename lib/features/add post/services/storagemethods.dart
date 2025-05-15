import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PostStorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(Uint8List file) async {
    String id = Uuid().v1();

    // Create a reference to a location in Firebase Storage
    Reference reference = _storage.ref().child('nposts').child(id);

    // Upload the file
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
