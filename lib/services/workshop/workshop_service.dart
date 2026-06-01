import 'package:autofinder/models/service_callback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/commentar_model.dart';

class WorkshopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workshops';

  Future<String> addWorkshop(WorkshopModel workshop) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(workshop.toMap());
      await docRef.update({'uid': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add workshop: $e');
    }
  }

  Future<WorkshopModel?> getWorkshopById(String workshopId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(workshopId).get();
      if (doc.exists) {
        return WorkshopModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<WorkshopModel?> workshopStream(String workshopId) {
    return _firestore
        .collection(_collection)
        .doc(workshopId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return WorkshopModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> getWorkshops(ServiceCallback callback) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      callback.onSuccessData(
        snapshot.docs
            .map(
              (doc) =>
                  WorkshopModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      callback.onErrorData('Failed to get workshops: $e');
      // throw Exception('Failed to get workshops: $e');
    } finally {
      callback.onFullFailed;
    }
  }

  Future<void> addComment(CommentarModel comment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('comments')
          .add(comment.toMap());
      await docRef.update({'uid': docRef.id});
      await _updateWorkshopRating(comment.workshopId);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> _updateWorkshopRating(String workshopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      if (snapshot.docs.isEmpty) {
        await _firestore.collection(_collection).doc(workshopId).update({
          'averageRating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0).toDouble();
      }

      double average = totalRating / snapshot.docs.length;
      await _firestore.collection(_collection).doc(workshopId).update({
        'averageRating': average,
        'totalReviews': snapshot.docs.length,
      });
    } catch (e) {
      print('Failed to update workshop rating: $e');
    }
  }

  Future<void> getComments(String workshopId, ServiceCallback callback) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('workshopId', isEqualTo: workshopId)
          .get();
      callback.onSuccessData(
        snapshot.docs
            .map(
              (doc) =>
                  CommentarModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      callback.onErrorData('Failed to get comments: $e');
    } finally {
      callback.onFullFailed?.call();
    }
  }

  Future<bool> checkUserHasReviewed(String workshopId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('workshopId', isEqualTo: workshopId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateComment(String commentId, int rating, String description) async {
    final doc = await _firestore.collection('comments').doc(commentId).get();
    if (doc.exists) {
      await _firestore.collection('comments').doc(commentId).update({
        'rating': rating,
        'description': description,
      });
      final workshopId = (doc.data() as Map<String, dynamic>)['workshopId'];
      if (workshopId != null) {
        await _updateWorkshopRating(workshopId);
      }
    }
  }

  Future<void> deleteComment(String commentId) async {
    final doc = await _firestore.collection('comments').doc(commentId).get();
    if (doc.exists) {
      final workshopId = (doc.data() as Map<String, dynamic>)['workshopId'];
      await _firestore.collection('comments').doc(commentId).delete();
      if (workshopId != null) {
        await _updateWorkshopRating(workshopId);
      }
    }
  }

  Future<void> addReplyToComment(String commentId, Map<String, dynamic> reply) async {
    await _firestore.collection('comments').doc(commentId).update({
      'replies': FieldValue.arrayUnion([reply]),
    });
  }
}
