import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class UploadYourTeamLogoUseCase {
  final FirebaseStorage _storage;
  UploadYourTeamLogoUseCase(this._storage);

  /// Возвращает downloadURL
  Future<String> call(
      String uid, {
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) async {
    final ref = _storage.ref('users/$uid/your_team/logo.jpg');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    return await ref.getDownloadURL();
  }
}
