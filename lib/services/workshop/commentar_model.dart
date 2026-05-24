class CommentarModel {
  final String? uid;
  final String userId;
  final int rating;
  final String description;
  final String workshopId;

  CommentarModel({
    required this.uid,
    required this.userId,
    required this.rating,
    required this.description,
    required this.workshopId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
      'rating': rating,
      'description': description,
    };
  }

  factory CommentarModel.fromMap(Map<String, dynamic> map) {
    return CommentarModel(
      uid: map['uid'],
      userId: map['userId'] ?? '',
      rating: map['rating'] ?? 0,
      description: map['description'] ?? '',
      workshopId: map['workshopId'] ?? '',
    );
  }
}
