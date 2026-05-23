import 'package:autofinder/services/workshop/operation_time_model.dart';

class WorkshopModel {
  final String? uid;
  final String title;
  final double longitude;
  final double latitude;
  final List<String> image;
  final List<OperationTimeModel>? operationTimes;

  WorkshopModel({
    required this.uid,
    required this.title,
    required this.longitude,
    required this.latitude,
    required this.image,
    this.operationTimes,
  });

  // Convert workshop info to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'longitude': longitude,
      'latitude': latitude,
      'image': image,
    };
  }

  // Create WorkshopModel from a Firestore Map
  factory WorkshopModel.fromMap(Map<String, dynamic> map) {
    return WorkshopModel(
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      longitude: map['longitude'] ?? 0.0,
      latitude: map['latitude'] ?? 0.0,
      image: List<String>.from(map['image'] ?? []),
    );
  }
}
