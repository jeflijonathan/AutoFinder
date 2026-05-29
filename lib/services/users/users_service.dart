import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:autofinder/models/api_response.dart';
import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/users/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autofinder/services/api_service.dart';

class UsersService extends APIService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _database.collection(
    'users',
  );

  void getUserByEmail(
    String email,
    ServiceCallback<UserModel?> callback,
  ) async {
    final ApiResponse<List<Map<String, dynamic>>> res = await getAllData(
      'users',
    );

    if (res.status == "success") {
      final filteredDocs = res.data
          ?.where((user) => user['email'] == email.trim())
          .toList();

      if (filteredDocs != null && filteredDocs.isNotEmpty) {
        final userData = filteredDocs.first;
        callback.onSuccessData(UserModel.fromMap(userData));
      } else {
        callback.onSuccessData(null);
      }
    }

    if (res.status == "error") {
      callback.onErrorData("Firestore Error: ${res.message}");
    }

    callback.onFullFailed?.call();
  }

  void createUser(
    UserModel data,
    String password,
    ServiceCallback<Map<String, dynamic>> callback,
  ) async {
    final docRef = _usersCollection.doc();

    final Map<String, dynamic> userData = data.toMap();
    userData['uid'] = docRef.id;
    userData['password'] = password;

    final ApiResponse<bool> res = await updateData(
      'users',
      docRef.id,
      userData,
    );

    if (res.status == "success") {
      callback.onSuccessData(userData);
    }

    if (res.status == "error") {
      callback.onErrorData("Firestore Error: ${res.message}");
    }

    callback.onFullFailed?.call();
  }

  Future<ApiResponse<String>> uploadProfilePicture(
    String uid,
    File imageFile,
  ) async {
    try {
      if (uid.isEmpty) {
        return ApiResponse.error("UID is empty", 400);
      }

      print("Upload started for UID: $uid. File path: ${imageFile.path}");
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      // Upload file
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      print("Calling putFile...");
      final TaskSnapshot snapshot = await ref.putFile(imageFile, metadata);
      print("putFile completed. State: ${snapshot.state}");

      // Check if successful
      if (snapshot.state == TaskState.success) {
        print("Calling getDownloadURL...");
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print("getDownloadURL success: $downloadUrl");
        return ApiResponse.success(downloadUrl);
      } else {
        return ApiResponse.error(
          "Upload task failed with state: ${snapshot.state}",
          500,
        );
      }
    } catch (e) {
      print("Exception caught in uploadProfilePicture: $e");
      return ApiResponse.error("Failed to upload image: $e", 500);
    }
  }

  void updateUser(
    String uid,
    Map<String, dynamic> data,
    ServiceCallback<bool> callback,
  ) async {
    final ApiResponse<bool> res = await updateData('users', uid, data);

    if (res.status == "success") {
      callback.onSuccessData(true);
    } else {
      callback.onErrorData("Firestore Error: ${res.message}");
    }
    callback.onFullFailed?.call();
  }
}
