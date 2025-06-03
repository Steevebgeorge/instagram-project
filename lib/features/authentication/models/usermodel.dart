class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String userName;
  final String bio;
  final List followers;
  final List following;
  final String about;
  final createdAt;
  final lastActive;
  final bool isOnline;
  final String pushToken;
  const UserModel(
      {required this.email,
      required this.uid,
      required this.photoUrl,
      required this.userName,
      required this.bio,
      required this.followers,
      required this.following,
      required this.about,
      required this.createdAt,
      required this.lastActive,
      required this.isOnline,
      required this.pushToken});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userName': userName,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'followers': followers,
        'following': following,
        'about': about,
        'createdAt': createdAt,
        'lastActive': lastActive,
        'isOnline': isOnline,
        'pushToken': pushToken,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      uid: json['uid'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      userName: json['userName'] ?? '',
      bio: json['bio'] ?? '',
      followers: json['followers'] ?? [],
      following: json['following'] ?? [],
      about: json['about'] ?? [],
      createdAt: json['createdAt'] ?? [],
      lastActive: json['lastActive'] ?? [],
      isOnline: json['isOnline'] ?? [],
      pushToken: json['pushToken'] ?? [],
    );
  }
}
