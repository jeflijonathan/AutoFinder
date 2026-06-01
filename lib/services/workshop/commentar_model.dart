class CommentarModel {
  final String? uid;
  final String userId;
  final int rating;
  final String description;
  final String workshopId;

  final String userName;
  final List<dynamic> replies;

  CommentarModel({
    required this.uid,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.description,
    required this.workshopId,
    this.replies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'description': description,
      'workshopId': workshopId,
      'replies': replies,
    };
  }

  factory CommentarModel.fromMap(Map<String, dynamic> map) {
    return CommentarModel(
      uid: map['uid'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      rating: map['rating'] ?? 0,
      description: map['description'] ?? '',
      workshopId: map['workshopId'] ?? '',
      replies: map['replies'] ?? [],
    );
  }
}
