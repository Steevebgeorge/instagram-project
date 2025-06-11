import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20page/models/chatmodel.dart';
import 'package:instagram/features/chat%20page/services/chat.dart';
import 'package:instagram/features/chat%20page/widgets/messagecard.dart';
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
  final List<MessageModel> _list = [];
  final TextEditingController messageController = TextEditingController();
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
              widget.user, messageController.text.trim(), widget.receiverId);
          messageController.clear();
          setState(
              () {}); // Forces a rebuild to show the new message immediately
        } catch (e) {
          print("Error sending message: $e");
          // Optionally show an error message to the user
        }
      }
    }

    return Scaffold(
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
                  itemCount: data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final messageData = data![index].data();
                    final message = MessageModel.fromJson(
                        messageData); // Assuming you have this method
                    return MessageCard(message: message);
                  },
                );
              },
            ),
          ),
          _inputbox(sendMessage),
        ],
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
                      onPressed: () {}, icon: Icon(Icons.emoji_emotions)),
                  Expanded(
                      child: TextField(
                    controller: messageController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "send your message.."),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.photo_library_rounded)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt)),
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
              Text(
                'last seen 5:20',
                style: TextStyle(fontSize: 13),
              ),
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
