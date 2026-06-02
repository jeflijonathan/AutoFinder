import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:flutter/material.dart';

class MyPostStateModel {
  final bool isLoading;
  final String errorMessage;
  final List<WorkshopModel> data;
  final WorkshopModel dataWorkshopById;

  MyPostStateModel({
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.dataWorkshopById,
  });

  MyPostStateModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    WorkshopModel? dataWorkshopById,
  }) {
    return MyPostStateModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      dataWorkshopById: dataWorkshopById ?? this.dataWorkshopById,
    );
  }
}

class MyPostProvider extends ChangeNotifier {
  MyPostStateModel _state = MyPostStateModel(
    isLoading: false,
    errorMessage: "",
    data: [],
    dataWorkshopById: WorkshopModel(
      uid: "",
      idUser: "",
      title: "",
      longitude: 0,
      latitude: 0,
      image: [],
      description: "",
      averageRating: 0,
      totalReviews: 0,
      phoneNumber: "",
      specialization: "",
      services: [],
      address: "",
    ),
  );

  MyPostStateModel get state => _state;

  void updateState({
    bool? isLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    WorkshopModel? dataWorkshopById,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      data: data,
      dataWorkshopById: dataWorkshopById,
    );
    notifyListeners();
  }
}
