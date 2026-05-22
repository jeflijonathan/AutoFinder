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
        callback.onSuccessData(null); // Tidak ditemukan, kembalikan null
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
}
