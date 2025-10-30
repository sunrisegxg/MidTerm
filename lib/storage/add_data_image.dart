import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StoreDataImageProfile {
  Future<String> uploadImageToStorage(String email, Uint8List file) async {
    try {
      Reference refRoot = _storage.ref();
      Reference refDirImages = refRoot.child('profileImage');
      Reference refImageToUpload = refDirImages.child(
        email.replaceAll('@', '_').replaceAll('.', '_'),
      );
      UploadTask uploadTask = refImageToUpload.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      log(error.toString());
      return "";
    }
  }
}
