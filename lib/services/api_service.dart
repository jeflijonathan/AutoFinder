import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autofinder/models/api_response.dart'; // Import model baru

class APIService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;

  // 1. GET ALL DATA (Mengembalikan List)
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllData(
    String endpoint,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _database.collection(endpoint).get();

      List<Map<String, dynamic>> listData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      return ApiResponse.success(listData); // Return status_code: 200
    } on FirebaseException catch (e) {
      // 400 Bad Request jika ada kesalahan query/permission dari Firebase
      return ApiResponse.error("Firestore Error: ${e.message}", 400);
    } catch (e) {
      // 500 Internal Server Error jika ada crash internal di code
      return ApiResponse.error("Internal Server Error: $e", 500);
    }
  }

  // 2. GET DATA BY ID (Mengembalikan Map tunggal)
  Future<ApiResponse<Map<String, dynamic>>> getDataById(
    String endpoint,
    String id,
  ) async {
    try {
      DocumentSnapshot docSnapshot = await _database
          .collection(endpoint)
          .doc(id)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return ApiResponse.success(data); // Return status_code: 200
      } else {
        // 404 Not Found jika dokumen tidak ada
        return ApiResponse.error("Dokumen dengan ID $id tidak ditemukan", 404);
      }
    } on FirebaseException catch (e) {
      return ApiResponse.error("Firestore Error: ${e.message}", 400);
    } catch (e) {
      return ApiResponse.error("Internal Server Error: $e", 500);
    }
  }

  // 3. UPDATE / SET DATA (Mengembalikan bool di dalam data atau kustomisasi code)
  Future<ApiResponse<bool>> updateData(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _database
          .collection(endpoint)
          .doc(id)
          .set(data, SetOptions(merge: true));

      // Menggunakan 201 Created atau tetap 200 OK
      return ApiResponse.success(
        true,
        message: "Data berhasil diperbarui",
        code: 200,
      );
    } on FirebaseException catch (e) {
      return ApiResponse.error("Firestore Error [UPDATE]: ${e.message}", 400);
    } catch (e) {
      return ApiResponse.error("Internal Server Error: $e", 500);
    }
  }

  // 4. DELETE DATA
  Future<ApiResponse<bool>> deleteData(String endpoint, String id) async {
    try {
      await _database.collection(endpoint).doc(id).delete();
      return ApiResponse.success(
        true,
        message: "Data berhasil dihapus",
        code: 200,
      );
    } on FirebaseException catch (e) {
      return ApiResponse.error("Firestore Error [DELETE]: ${e.message}", 400);
    } catch (e) {
      return ApiResponse.error("Internal Server Error: $e", 500);
    }
  }
}
