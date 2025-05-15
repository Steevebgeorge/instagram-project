import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/profile/screens/profile.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: widget.snap['uid'],
        ),
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                widget.snap['profilePic'],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        children: [
                          TextSpan(
                            text: '${widget.snap['name']}      ',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat.yMMMd()
                                .format(widget.snap['date'].toDate()),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.snap['text'],
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.favorite_outline),
            )
          ],
        ),
      ),
    );
  }
}
//
