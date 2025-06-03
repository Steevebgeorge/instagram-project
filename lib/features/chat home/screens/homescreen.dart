import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/features/chat%20home/widget/chatcard.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserProvider>(context).getuser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        body: Center(
          child: Text("Login to continue"),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = UserModel.fromJson(
            userSnapshot.data!.data() as Map<String, dynamic>);

        return buildChatHome(userData);
      },
    );
  }

  Widget buildChatHome(UserModel user) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          centerTitle: true,
          title: Text(
            user.userName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.video_call_outlined, size: 28),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.edit_outlined, size: 26),
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey[600], size: 22),
                  suffixIcon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: _searchController.text.isNotEmpty
                        ? IconButton(
                            key: ValueKey("clear"),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                isSearching = false;
                                _searchResults = [];
                              });
                            },
                            icon: Icon(Icons.clear,
                                color: Colors.grey[600], size: 20),
                          )
                        : SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    isSearching = value.isNotEmpty;
                    _searchResults = _allUsers
                        .where((u) => u.userName
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            // 🗂 User List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No Data found'));
                  }

                  final data = snapshot.data!.docs;
                  List<UserModel> finalData = data
                      .map((e) =>
                          UserModel.fromJson(e.data() as Map<String, dynamic>))
                      .where((otherUser) =>
                          user.following.contains(otherUser.uid) &&
                          otherUser.uid != user.uid)
                      .toList();

                  // Update _allUsers only if necessary to avoid constant rebuilds
                  if (_allUsers.length != finalData.length) {
                    _allUsers = finalData;
                  }

                  final displayList = isSearching ? _searchResults : _allUsers;

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) =>
                        ChatCard(user: displayList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
