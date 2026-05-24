import 'package:autofinder/services/workshop/operation_time_model.dart';

class WorkshopModel {
  final String? uid;
  final String title;
  final double longitude;
  final double latitude;
  final List<String> image;
  final List<OperationTimeModel>? operationTimes;
  final String phoneNumber;
  final String description;
  final String specialization;
  final List<String> services;
  final String address;

  WorkshopModel({
    required this.uid,
    required this.title,
    required this.longitude,
    required this.latitude,
    required this.image,
    this.operationTimes,
    required this.phoneNumber,
    required this.description,
    required this.specialization,
    required this.services,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'longitude': longitude,
      'latitude': latitude,
      'image': image,
      'phoneNumber': phoneNumber,
      'description': description,
      'specialization': specialization,
      'services': services,
      'address': address,
      'operationTimes': operationTimes?.map((e) => e.toMap()).toList(),
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
      phoneNumber: map['phoneNumber'] ?? '',
      description: map['description'] ?? '',
      specialization: map['specialization'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      address: map['address'] ?? '',
      operationTimes: map['operationTimes'] != null
          ? List<OperationTimeModel>.from(
              map['operationTimes'].map((x) => OperationTimeModel(
                    day: x['day'],
                    openTime: x['openTime'],
                    closeTime: x['closeTime'],
                  )))
          : null,
    );
  }
}
