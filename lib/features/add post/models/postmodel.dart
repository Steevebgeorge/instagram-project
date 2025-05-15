class PostModel {
  final String description;
  final String uid;
  final String userName;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profileImage;
  final likes;
  final String location;

  const PostModel({
    required this.description,
    required this.uid,
    required this.userName,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profileImage,
    required this.likes,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userName': userName,
        'description': description,
        'postId': postId,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'likes': likes,
        'location': location,
      };

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      description: json['description'] ?? '',
      uid: json['uid'] ?? '',
      userName: json['userName'] ?? '',
      postId: json['postId'] ?? '',
      datePublished: json['datePublished'] ?? '',
      postUrl: json['postUrl'] ?? [],
      profileImage: json['profileImage'] ?? [],
      likes: json['likes'] ?? [],
      location: json['location'] ?? [],
    );
  }
}
