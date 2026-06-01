import 'package:autofinder/services/workshop/commentar_model.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:flutter/material.dart';

class DetailStateModel {
  final bool isLoading;
  final String errorMessage;
  final List<CommentarModel> comments;
  final WorkshopModel? workshop;

  DetailStateModel({
    required this.isLoading,
    required this.errorMessage,
    required this.comments,
    this.workshop,
  });

  DetailStateModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CommentarModel>? comments,
    WorkshopModel? workshop,
  }) {
    return DetailStateModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      comments: comments ?? this.comments,
      workshop: workshop ?? this.workshop,
    );
  }
}

class DetailPageProvider extends ChangeNotifier {
  DetailStateModel _state = DetailStateModel(
    isLoading: false,
    errorMessage: "",
    comments: [],
  );

  DetailStateModel get state => _state;

  void updateState({
    bool? isLoading,
    String? errorMessage,
    List<CommentarModel>? comments,
    WorkshopModel? workshop,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      comments: comments,
      workshop: workshop,
    );
    notifyListeners();
  }
}
