import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';
import 'package:instagram/features/chat%20page/screens/chatpage.dart';
import 'package:instagram/features/chat%20page/services/chat.dart';
import 'package:instagram/features/home/services/activites.dart';

class ChatCard extends StatefulWidget {
  final UserModel user;

  const ChatCard({
    super.key,
    required this.user,
  });

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  MessageModel? _message;
  ChatFeatures chatfeatures = ChatFeatures();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              user: widget.user,
              receiverId: widget.user.uid,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: StreamBuilder(
          stream: chatfeatures.getLastMessage(widget.user, widget.user.uid),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                    [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.user.photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.userName,
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        _message != null
                            ? (_message!.type == MessageType.image
                                ? 'image'
                                : _message!.message)
                            : widget.user.about,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13),
                      )
                    ],
                  ),
                  Spacer(),
                  StreamBuilder(
                    stream: AppActivities().getUserInfo(widget.user),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Text('User not found');
                      } else {
                        final userData = snapshot.data?.docs;
                        final list = userData
                                ?.map((e) => UserModel.fromJson(e.data()))
                                .toList() ??
                            [];
                        return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: list[0].isOnline
                                    ? Colors.green
                                    : Colors.red));
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
