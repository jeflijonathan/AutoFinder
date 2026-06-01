import 'package:autofinder/models/params.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/views/home/utils/filter_mapped.dart';
import 'package:flutter/material.dart';

class HomeStateModel {
  final bool isLoading;
  final String errorMessage;
  final List<WorkshopModel> data;
  final FilterMapped params;

  HomeStateModel({
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.params,
  });

  HomeStateModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    FilterMapped? params,
  }) {
    return HomeStateModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      params: params ?? this.params,
    );
  }
}

class HomePageProvider extends ChangeNotifier {
  late HomeStateModel _state = HomeStateModel(
    isLoading: false,
    errorMessage: "",
    data: [],
    params: FilterMapped(
      values: "",
      limit: 5,
      currentLatitude: "",
      currentLongitude: "",
    ),
  );

  HomeStateModel get state => _state;

  void updateState({
    bool? isLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    FilterMapped? params,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      data: data,
      params: params,
    );
    notifyListeners();
  }
}
