class OperationTimeModel {
  final String day;
  final String openTime;
  final String closeTime;

  OperationTimeModel({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  Map<String, dynamic> toMap() {
    return {'day': day, 'openTime': openTime, 'closeTime': closeTime};
  }
}
