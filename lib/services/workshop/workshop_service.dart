import 'package:autofinder/models/service_callback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/commentar_model.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class WorkshopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workshops';

  Future<String> addWorkshop(WorkshopModel workshop) async {
    try {
      Map<String, dynamic> data = workshop.toMap();
      final GeoFirePoint geoFirePoint = GeoFirePoint(GeoPoint(workshop.latitude, workshop.longitude));
      data['geo'] = geoFirePoint.data;

      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(data);
      await docRef.update({'uid': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add workshop: $e');
    }
  }

  Future<void> getWorkshopById(
    String workshopId,
    ServiceCallback callback,
  ) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(workshopId)
          .get();

      callback.onSuccessData(
        WorkshopModel.fromMap(doc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      callback.onErrorData('Failed to get workshop by ID: $e');
    } finally {
      callback.onFullFailed?.call();
    }
  }

  Stream<WorkshopModel?> workshopStream(String workshopId) {
    return _firestore.collection(_collection).doc(workshopId).snapshots().map((
      doc,
    ) {
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
    } finally {
      callback.onFullFailed?.call();
    }
  }

  Future<void> getNearbyWorkshops(
    double lat,
    double lng,
    double radiusInKm,
    ServiceCallback callback,
  ) async {
    try {
      GeoCollectionReference<Map<String, dynamic>> geoCollection =
          GeoCollectionReference(_firestore.collection(_collection));

      List<DocumentSnapshot<Map<String, dynamic>>> docs = await geoCollection.fetchWithin(
        center: GeoFirePoint(GeoPoint(lat, lng)),
        radiusInKm: radiusInKm,
        field: 'geo',
        geopointFrom: (data) =>
            (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
        strictMode: true,
      );

      callback.onSuccessData(
        docs
            .map((doc) => WorkshopModel.fromMap(doc.data()!))
            .toList(),
      );
    } catch (e) {
      callback.onErrorData('Failed to get nearby workshops: $e');
    } finally {
      callback.onFullFailed?.call();
    }
  }

  Future<void> migrateWorkshopsToGeohash() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('geo')) {
          final lat = (data['latitude'] ?? 0.0).toDouble();
          final lng = (data['longitude'] ?? 0.0).toDouble();
          final GeoFirePoint geoFirePoint = GeoFirePoint(GeoPoint(lat, lng));
          batch.update(doc.reference, {'geo': geoFirePoint.data});
        }
      }
      await batch.commit();
      print('Migration to geohash completed');
    } catch (e) {
      print('Migration failed: $e');
    }
  }

  Future<void> getWorkshopsByUserId(
    String userId,
    ServiceCallback callback,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('idUser', isEqualTo: userId)
          .get();
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
    } finally {
      callback.onFullFailed?.call();
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

  Future<void> updateComment(
    String commentId,
    int rating,
    String description,
  ) async {
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

  Future<void> addReplyToComment(
    String commentId,
    Map<String, dynamic> reply,
  ) async {
    await _firestore.collection('comments').doc(commentId).update({
      'replies': FieldValue.arrayUnion([reply]),
    });
  }

  Future<void> updateWorkshop(
    String workshopId,
    WorkshopModel workshop,
    ServiceCallback callback,
  ) async {
    try {
      Map<String, dynamic> data = workshop.toMap();
      final GeoFirePoint geoFirePoint = GeoFirePoint(GeoPoint(workshop.latitude, workshop.longitude));
      data['geo'] = geoFirePoint.data;

      await _firestore
          .collection(_collection)
          .doc(workshopId)
          .update(data);

      callback.onSuccessData([]);
    } catch (e) {
      callback.onErrorData('Failed to update workshop: $e');
    } finally {
      callback.onFullFailed?.call();
    }
  }

  Future<void> deleteWorkshop(
    String workshopId,
    ServiceCallback callback,
  ) async {
    try {
      final commentSnapshot = await _firestore
          .collection('comments')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      final batch = _firestore.batch();
      for (var doc in commentSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_firestore.collection(_collection).doc(workshopId));

      await batch.commit();

      callback.onSuccessData([]);
    } catch (e) {
      callback.onErrorData('Failed to delete workshop: $e');
    } finally {
      callback.onFullFailed?.call();
    }
  }
}
