import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/commentar_model.dart';

class WorkshopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workshops';

  Future<String> addWorkshop(WorkshopModel workshop) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(workshop.toMap());
      await docRef.update({'uid': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add workshop: $e');
    }
  }

  Future<List<WorkshopModel>> getWorkshops() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => WorkshopModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get workshops: $e');
    }
  }

  Future<void> addComment(CommentarModel comment) async {
     try {
       DocumentReference docRef = await _firestore.collection('comments').add(comment.toMap());
       await docRef.update({'uid': docRef.id});
     } catch (e) {
       throw Exception('Failed to add comment: $e');
     }
  }
}
