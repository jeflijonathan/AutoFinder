class FilterMapped {
  String values;
  int limit;
  String currentLatitude;
  String currentLongitude;

  FilterMapped({
    required this.values,
    required this.limit,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  FilterMapped copyWith({
    String? values,
    int? limit,
    String? currentLatitude,
    String? currentLongitude,
  }) {
    return FilterMapped(
      values: values ?? this.values,
      limit: limit ?? this.limit,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}
