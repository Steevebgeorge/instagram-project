import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/comments/screens/commentscreen.dart';
import 'package:instagram/features/feed/services/deletepost.dart';
import 'package:instagram/features/feed/services/like.dart';
import 'package:instagram/features/feed/widgets/likeanimation.dart';
import 'package:instagram/features/profile/screens/profile.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    super.key,
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Stream<QuerySnapshot> commentsStream;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    commentsStream = FirebaseFirestore.instance
        .collection('nposts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .snapshots();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      try {
        dateTime = DateTime.parse(timestamp);
      } catch (e) {
        return timestamp;
      }
    } else {
      return 'Invalid date';
    }

    return DateFormat.yMMMd().format(dateTime);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await PostServices().deletePost(postId);
      _showSnackBar('Post deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting post: $e');
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Post'),
              content: const Text('Are you sure you want to delete this post?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;

    if (user == null) {
      // User data is not yet loaded
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(uid: widget.snap['uid']),
                    ));
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(widget.snap['profileImage']),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(uid: widget.snap['uid']),
                              ));
                            },
                            child: Text(widget.snap['userName']),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {},
                            child: Text(
                              widget.snap['location'],
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                iconbutton()
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await LikeMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.contain,
                  ),
                ),
                AnimatedOpacity(
                  opacity: isAnimating ? 1 : 0,
                  duration: const Duration(microseconds: 10),
                  child: LikeAnimation(
                    duration: const Duration(milliseconds: 250),
                    onEnd: () {
                      setState(() {
                        isAnimating = false;
                      });
                    },
                    isAnimated: isAnimating,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 130,
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              LikeAnimation(
                isAnimated: widget.snap['likes'].contains(user.uid),
                smallLiked: true,
                child: IconButton(
                  onPressed: () async {
                    await LikeMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                ),
              ),
              Text('${widget.snap['likes'].length}'),
              StreamBuilder<QuerySnapshot>(
                stream: commentsStream,
                builder: (context, snapshot) {
                  int commentCount = 0;
                  if (snapshot.hasData) {
                    commentCount = snapshot.data!.docs.length;
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                CommentScreen(snap: widget.snap),
                          ));
                        },
                        icon: const Icon(Icons.comment_outlined),
                      ),
                      Text('$commentCount'),
                    ],
                  );
                },
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['userName'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextSpan(
                          text: '   ${widget.snap['description']}',
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _formatTimestamp(
                    widget.snap['datePublished'],
                  ),
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
          ),
          SizedBox(
            height: 30,
          )
          // Divider(
          //   color: Colors.grey[900],
          // )
        ],
      ),
    );
  }

  Widget iconbutton() {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;

    return IconButton(
        onPressed: () {
          showDialog(
            useRootNavigator: false,
            context: context,
            builder: (context) => Dialog(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shrinkWrap: true,
                children: [
                  if (widget.snap['uid'] == user!.uid)
                    InkWell(
                      onTap: () async {
                        bool isconfirm = await _showDeleteConfirmation(context);
                        if (isconfirm) {
                          await deletePost(widget.snap['postId']);
                        }

                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                        child: Row(
                          spacing: 15,
                          children: [Icon(Icons.delete), Text('Delete')],
                        ),
                      ),
                    ),
                  if (widget.snap['uid'] == user.uid)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                        child: Row(
                          spacing: 15,
                          children: [
                            Icon(Icons.edit_note_rounded),
                            Text('Edit Post')
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                      child: Row(
                        spacing: 15,
                        children: [Icon(Icons.star), Text('Add to favourite')],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                      child: Row(
                        spacing: 15,
                        children: [
                          Icon(Icons.account_circle_outlined),
                          Text('About this Account')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                      child: Row(
                        spacing: 15,
                        children: [Icon(Icons.report), Text('Report Post')],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        icon: Icon(Icons.more_vert_outlined));
  }
}
