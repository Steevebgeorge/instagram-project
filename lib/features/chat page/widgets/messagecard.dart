import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';
import 'package:instagram/features/chat%20page/services/chat.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard({
    super.key,
    required this.message,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool onMyMessageTapp = false;
  bool recMessageTapp = false;

  String formatTimestamp(dynamic timestamp) {
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

    return DateFormat(' MMM d, h:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();

    if (widget.message.read.isEmpty) {
      log("message updated");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatFeatures().updateMessageSeen(widget.message.fromId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;
    if (user == null) {
      return Center(
        child: Text("login to continue"),
      );
    }

    return user.uid == widget.message.fromId ? _userCard() : _contactChatCard();
  }

  Widget _userCard() {
    final scsize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        setState(() {
          onMyMessageTapp = !onMyMessageTapp;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: scsize.width * .04, vertical: scsize.width * .04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      widget.message.type == MessageType.image
                          ? scsize.width * 0.029
                          : scsize.width * 0.04,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                    ),
                    child: widget.message.type == MessageType.text
                        ? Text(
                            widget.message.message,
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          )
                        : CachedNetworkImage(
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.5,
                            imageUrl: widget.message.message,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error_outline),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 10,
                    children: [
                      onMyMessageTapp
                          ? Text(formatTimestamp(widget.message.sent))
                          : SizedBox.shrink(),
                      onMyMessageTapp && widget.message.read.isNotEmpty
                          ? Icon(
                              Icons.done_all,
                              color: Colors.blue,
                            )
                          : SizedBox.shrink(),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _contactChatCard() {
    final scsize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        setState(() {
          recMessageTapp = !recMessageTapp;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: scsize.width * .04, vertical: scsize.width * .04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      scsize.width * 0.04,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    ),
                    child: widget.message.type == MessageType.text
                        ? Text(
                            widget.message.message,
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          )
                        : CachedNetworkImage(
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.5,
                            imageUrl: widget.message.message,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error_outline),
                          ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  recMessageTapp
                      ? Text(formatTimestamp(widget.message.sent))
                      : SizedBox.shrink()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
