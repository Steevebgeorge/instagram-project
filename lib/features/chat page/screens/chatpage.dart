import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';
import 'package:instagram/features/chat%20page/services/chat.dart';
import 'package:instagram/features/chat%20page/widgets/messagecard.dart';
import 'package:instagram/features/home/services/activites.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;
  final String receiverId;
  const ChatScreen({super.key, required this.user, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatFeatures _chatFeatures = ChatFeatures();
  // final List<MessageModel> _list = [];
  bool loadImojis = false;
  Uint8List? image;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController imojiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;
    if (user == null) {
      return Center(
        child: Text("login to continue"),
      );
    }

    void sendMessage() async {
      if (messageController.text.isNotEmpty) {
        try {
          await _chatFeatures.storeMessage(
              messageController.text.trim(), widget.receiverId);
          messageController.clear();
          setState(
              () {}); // Forces a rebuild to show the new message immediately
        } catch (e) {
          print("Error sending message: $e");
          // Optionally show an error message to the user
        }
      }
    }

    void sendImage(Uint8List file, String receiverId) async {
      try {
        await ChatFeatures().uploadChatImageToStorage(file, receiverId);
      } catch (e) {
        log("Error sending image: $e");
      }
    }

    if (image != null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  image = null;
                });
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: Image.memory(
                  image!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sendImage(image!, widget.receiverId);
                        setState(() {
                          image = null;
                        });
                      },
                      icon: Icon(Icons.send),
                      label: Text("Send"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          image = null;
                        });
                      },
                      icon: Icon(Icons.cancel),
                      label: Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (loadImojis) {
          setState(() {
            loadImojis = false;
          });
        }
      },
      child: Scaffold(
        appBar: _appbar(),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: ChatFeatures().getMessages(user.uid, widget.receiverId),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages yet. Say hi!'));
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final messageData = data![index].data();
                      final message = MessageModel.fromJson(messageData);
                      return MessageCard(message: message);
                    },
                  );
                },
              ),
            ),
            _inputbox(sendMessage),
            if (loadImojis)
              EmojiPicker(
                textEditingController: messageController,
                config: Config(
                  height: 320,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _inputbox(VoidCallback action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        loadImojis = !loadImojis;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions),
                  ),
                  Expanded(
                      child: TextField(
                    controller: messageController,
                    maxLines: null,
                    onTap: () {
                      if (loadImojis) {
                        setState(() {
                          loadImojis = !loadImojis;
                        });
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "send your message.."),
                  )),
                  IconButton(
                      onPressed: () async {
                        Uint8List? file = await getImage(ImageSource.gallery);
                        if (file != null) {
                          setState(() {
                            image = file;
                          });
                        }
                      },
                      icon: Icon(Icons.photo_library_rounded)),
                  IconButton(
                      onPressed: () async {
                        Uint8List? file = await getImage(ImageSource.camera);
                        if (file != null) {
                          setState(() {
                            image = file;
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt)),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 8),
            shape: CircleBorder(),
            color: Colors.red[300],
            onPressed: action,
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      elevation: 3,
      title: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
              widget.user.photoUrl,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.userName,
                style: TextStyle(fontSize: 22),
              ),
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
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('User not found');
                  } else {
                    final userData = snapshot.data?.docs;
                    final list = userData
                            ?.map((e) => UserModel.fromJson(e.data()))
                            .toList() ??
                        [];
                    return Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'online'
                              : getFormattedLastSeen(
                                  (list[0].lastActive as Timestamp).toDate(),
                                )
                          : getFormattedLastSeen(
                              (widget.user.lastActive as Timestamp).toDate(),
                            ),
                      style: TextStyle(fontSize: 13),
                    );
                  }
                },
              )
            ],
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.phone),
        ),
        SizedBox(width: 15),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.video_call),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
