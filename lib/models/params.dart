class ParamsModel {
  final Map<String, dynamic> params;

  ParamsModel({required this.params});

  factory ParamsModel.fromJson(Map<String, dynamic> json) {
    return ParamsModel(params: json);
  }

  Map<String, dynamic> toJson() {
    return params;
  }
}
