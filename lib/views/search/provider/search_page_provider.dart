import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:flutter/material.dart';

class SearchStateModel {
  final bool isLoading;
  final bool searchLoading;
  final String errorMessage;
  final List<WorkshopModel> data;
  final String searchQuery;
  final bool openNow;
  final bool topRated;
  final List<String> selectedSpecializations;

  SearchStateModel({
    required this.isLoading,
    required this.searchLoading,
    required this.errorMessage,
    required this.data,
    required this.searchQuery,
    required this.openNow,
    required this.topRated,
    required this.selectedSpecializations,
  });

  SearchStateModel copyWith({
    bool? isLoading,
    bool? searchLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    String? searchQuery,
    bool? openNow,
    bool? topRated,
    List<String>? selectedSpecializations,
  }) {
    return SearchStateModel(
      isLoading: isLoading ?? this.isLoading,
      searchLoading: searchLoading ?? this.searchLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
      openNow: openNow ?? this.openNow,
      topRated: topRated ?? this.topRated,
      selectedSpecializations: selectedSpecializations ?? this.selectedSpecializations,
    );
  }
}

class SearchPageProvider extends ChangeNotifier {
  SearchStateModel _state = SearchStateModel(
    isLoading: false,
    searchLoading: false,
    errorMessage: "",
    data: [],
    searchQuery: "",
    openNow: false,
    topRated: false,
    selectedSpecializations: [],
  );

  SearchStateModel get state => _state;

  void updateState({
    bool? isLoading,
    bool? searchLoading,
    String? errorMessage,
    List<WorkshopModel>? data,
    String? searchQuery,
    bool? openNow,
    bool? topRated,
    List<String>? selectedSpecializations,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      searchLoading: searchLoading,
      errorMessage: errorMessage,
      data: data,
      searchQuery: searchQuery,
      openNow: openNow,
      topRated: topRated,
      selectedSpecializations: selectedSpecializations,
    );
    notifyListeners();
  }
}
